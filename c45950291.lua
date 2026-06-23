--RUM－アストラル・フォース
-- 效果：
-- ①：以自己场上1只阶级最高的超量怪兽为对象才能发动。和那只自己怪兽相同种族·属性而阶级高2阶的1只怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
-- ②：这张卡在墓地存在的场合，自己抽卡阶段的抽卡前才能发动。这张卡加入手卡。这个效果发动的回合，自己不能进行通常抽卡，不能用「升阶魔法-星光之力」的效果以外把怪兽特殊召唤。
function c45950291.initial_effect(c)
	-- 效果①：以自己场上1只阶级最高的超量怪兽为对象才能发动。和那只自己怪兽相同种族·属性而阶级高2阶的1只怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c45950291.target)
	e1:SetOperation(c45950291.activate)
	c:RegisterEffect(e1)
	-- 效果②：这张卡在墓地存在的场合，自己抽卡阶段的抽卡前才能发动。这张卡加入手卡。这个效果发动的回合，自己不能进行通常抽卡，不能用「升阶魔法-星光之力」的效果以外把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45950291,0))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PREDRAW)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c45950291.thcon)
	e2:SetCost(c45950291.thcost)
	e2:SetTarget(c45950291.thtg)
	e2:SetOperation(c45950291.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查场上是否存在阶级高于rk的怪兽
function c45950291.cfilter(c,rk)
	return c:IsFaceup() and c:GetRank()>rk
end
-- 过滤函数：检查目标怪兽是否满足作为对象的条件（是超量怪兽、没有更高阶级的怪兽、额外卡组有符合条件的怪兽、必须成为素材）
function c45950291.filter1(c,e,tp)
	local rk=c:GetRank()
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		-- 检查场上是否存在阶级高于目标怪兽的怪兽
		and not Duel.IsExistingMatchingCard(c45950291.cfilter,tp,LOCATION_MZONE,0,1,nil,rk)
		-- 检查额外卡组是否存在阶级高2阶且种族属性相同的怪兽
		and Duel.IsExistingMatchingCard(c45950291.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk+2,c:GetRace(),c:GetAttribute(),c:GetCode())
		-- 检查目标怪兽是否满足成为超量素材的条件
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 过滤函数：检查额外卡组中是否存在符合条件的怪兽（阶级、种族、属性、能成为素材、能特殊召唤、有召唤空位）
function c45950291.filter2(c,e,tp,mc,rk,rc,att,code)
	if c:GetOriginalCode()==6165656 and code~=48995978 then return false end
	return c:IsRank(rk) and c:IsRace(rc) and c:IsAttribute(att) and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		-- 检查目标怪兽是否有足够的召唤空位
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 设置效果①的目标选择逻辑
function c45950291.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c45950291.filter1(chkc,e,tp) end
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c45950291.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,c45950291.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果①的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的处理函数
function c45950291.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否满足成为超量素材的条件
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c45950291.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+2,tc:GetRace(),tc:GetAttribute(),tc:GetCode())
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将目标怪兽的叠放卡叠放到新召唤的怪兽上
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将目标怪兽叠放到新召唤的怪兽上
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将符合条件的怪兽特殊召唤
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
-- 效果②的发动条件
function c45950291.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为当前回合玩家
	return tp==Duel.GetTurnPlayer()
end
-- 效果②的发动费用
function c45950291.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以进行通常抽卡且未进行过特殊召唤
	if chk==0 then return aux.IsPlayerCanNormalDraw(tp) and Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	local c=e:GetHandler()
	-- 创建禁止特殊召唤的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c45950291.splimit)
	-- 注册禁止特殊召唤的效果
	Duel.RegisterEffect(e1,tp)
	-- 创建禁止通常抽卡的效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetCode(63060238)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册禁止通常抽卡的效果
	Duel.RegisterEffect(e2,tp)
	-- 使玩家放弃通常抽卡
	aux.GiveUpNormalDraw(e,tp,EFFECT_FLAG_OATH)
end
-- 限制特殊召唤的函数
function c45950291.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not se:GetHandler():IsCode(45950291)
end
-- 设置效果②的处理信息
function c45950291.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置效果②的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果②的处理函数
function c45950291.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡加入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 确认对方查看该卡
		Duel.ConfirmCards(1-tp,c)
	end
end
