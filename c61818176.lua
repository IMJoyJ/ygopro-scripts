--ゴーストリック・リフォーム
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以自己场上1张「鬼计」场地魔法卡为对象才能发动。那张卡回到持有者手卡。那之后，可以从手卡·卡组把1张场地魔法卡发动。
-- ②：把墓地的这张卡除外，以自己场上1只「鬼计」超量怪兽为对象才能发动。和那只自己怪兽卡名不同的1只「鬼计」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
function c61818176.initial_effect(c)
	-- ①：以自己场上1张「鬼计」场地魔法卡为对象才能发动。那张卡回到持有者手卡。那之后，可以从手卡·卡组把1张场地魔法卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c61818176.target)
	e1:SetOperation(c61818176.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只「鬼计」超量怪兽为对象才能发动。和那只自己怪兽卡名不同的1只「鬼计」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61818176,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,61818176)
	-- 设置效果2的Cost为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c61818176.sptg)
	e2:SetOperation(c61818176.spop)
	c:RegisterEffect(e2)
end
-- 效果1的发动准备与对象选择
function c61818176.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场地区域的卡
	local tc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	if chkc then return false end
	if chk==0 then return tc and tc:IsFaceup() and tc:IsSetCard(0x8d) and tc:IsAbleToHand() and tc:IsCanBeEffectTarget(e) end
	-- 检查当前是否处于阶段开始时的非活动状态，并设置标记（用于处理在非自己回合发动场地魔法的时点问题）
	if not Duel.CheckPhaseActivity() then e:SetLabel(1) else e:SetLabel(0) end
	-- 将获取的场地魔法卡设为效果对象
	Duel.SetTargetCard(tc)
	-- 设置操作信息为将该卡送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
end
-- 过滤手卡·卡组中可以发动的场地魔法卡
function c61818176.actfilter(c,tp)
	return c:IsType(TYPE_FIELD) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- 效果1的处理函数
function c61818176.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的场地魔法卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍符合条件，则将其送回持有者手卡
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 若在非活动状态下发动，则注册临时标记以允许在非自己回合发动场地魔法
		if e:GetLabel()==1 then Duel.RegisterFlagEffect(tp,15248873,RESET_CHAIN,0,1) end
		-- 获取手卡·卡组中满足发动条件的场地魔法卡
		local g=Duel.GetMatchingGroup(c61818176.actfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,tp)
		-- 重置临时标记
		Duel.ResetFlagEffect(tp,15248873)
		-- 若存在可发动的场地魔法，玩家可以选择是否发动
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(61818176,1)) then  --"是否把场地魔法卡发动？"
			-- 中断当前效果处理，使后续的发动处理不与回手卡同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要放置到场上的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
			local sg=g:Select(tp,1,1,nil)
			local sc=sg:GetFirst()
			-- 将选择的场地魔法卡表侧表示移动到自己的场地区域并适用其效果
			Duel.MoveToField(sc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
			local te=sc:GetActivateEffect()
			te:UseCountLimit(tp,1,true)
			local tep=sc:GetControler()
			local cost=te:GetCost()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
			-- 触发场地魔法发动的相关事件
			Duel.RaiseEvent(sc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
		end
	end
end
-- 过滤自己场上表侧表示的「鬼计」超量怪兽，且额外卡组存在可重叠召唤的卡
function c61818176.filter1(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x8d)
		-- 检查额外卡组是否存在满足特殊召唤条件的、卡名不同的「鬼计」超量怪兽
		and Duel.IsExistingMatchingCard(c61818176.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetCode())
		-- 检查该怪兽是否满足必须作为超量素材的限制
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 过滤额外卡组中可用于重叠特殊召唤的「鬼计」超量怪兽
function c61818176.filter2(c,e,tp,mc,code)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x8d) and not c:IsCode(code) and mc:IsCanBeXyzMaterial(c)
		-- 检查该怪兽是否能以超量召唤方式特殊召唤，且额外怪兽区域有空位
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果2的发动准备与对象选择
function c61818176.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c61818176.filter1(chkc,e,tp) end
	-- 在发动时，检查自己场上是否存在符合条件的「鬼计」超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c61818176.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只「鬼计」超量怪兽作为效果对象
	Duel.SelectTarget(tp,c61818176.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息为从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果2的处理函数
function c61818176.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的「鬼计」超量怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否满足必须作为超量素材的限制，若不满足则结束处理
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只卡名不同的「鬼计」超量怪兽
	local g=Duel.SelectMatchingCard(tp,c61818176.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetCode())
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将原超量怪兽持有的超量素材转移给新特殊召唤的怪兽
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将作为对象的原超量怪兽重叠作为新怪兽的超量素材
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将新超量怪兽以超量召唤的形式表侧表示特殊召唤
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
