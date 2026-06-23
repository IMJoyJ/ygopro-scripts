--RUM－レヴォリューション・フォース
-- 效果：
-- ①：可以把发动回合的以下效果发动。
-- ●自己回合：以自己场上1只「急袭猛禽」超量怪兽为对象才能发动。阶级高1阶的1只「急袭猛禽」怪兽在作为对象的自己怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
-- ●对方回合：以对方场上1只没有超量素材的超量怪兽为对象才能发动。得到那只超量怪兽的控制权。那之后，阶级高1阶的1只「急袭猛禽」怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
function c43476205.initial_effect(c)
	-- 创建升阶魔法-革命之力的发动效果，设置为自由连锁、取对象、特殊召唤类别，并注册目标和效果处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c43476205.target)
	e1:SetOperation(c43476205.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数1：检查自己场上的超量怪兽是否满足条件（有阶级、正面表示、属于急袭猛禽族、能从额外卡组特殊召唤阶级高1阶的急袭猛禽怪兽、必须作为超量素材）
function c43476205.filter1(c,e,tp)
	local rk=c:GetRank()
	return rk>0 and c:IsFaceup() and c:IsSetCard(0xba)
		-- 检查是否存在满足条件的额外卡组怪兽（阶级高1阶的急袭猛禽怪兽）
		and Duel.IsExistingMatchingCard(c43476205.filter3,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk+1)
		-- 检查目标怪兽是否必须作为超量素材
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 过滤函数2：检查对方场上的超量怪兽是否满足条件（有阶级、正面表示、无超量素材、能改变控制权、必须作为超量素材、能从额外卡组特殊召唤阶级高1阶的急袭猛禽怪兽）
function c43476205.filter2(c,e,tp)
	local rk=c:GetRank()
	-- 检查目标怪兽是否满足条件（有阶级、正面表示、无超量素材、能改变控制权、必须作为超量素材）
	return rk>0 and c:IsFaceup() and c:GetOverlayCount()==0 and c:IsControlerCanBeChanged() and aux.MustMaterialCheck(c,1-tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查是否存在满足条件的额外卡组怪兽（阶级高1阶的急袭猛禽怪兽）
		and Duel.IsExistingMatchingCard(c43476205.filter3,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk+1)
end
-- 过滤函数3：检查额外卡组中的怪兽是否满足条件（阶级等于指定阶级、属于急袭猛禽族、能成为目标怪兽的超量素材、能特殊召唤、场上空位足够）
function c43476205.filter3(c,e,tp,mc,rk)
	return c:IsRank(rk) and c:IsSetCard(0xba) and mc:IsCanBeXyzMaterial(c)
		-- 检查目标怪兽是否能特殊召唤且场上空位足够
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 设置效果目标选择逻辑，根据回合玩家决定选择自己场上的怪兽或对方场上的怪兽，并设置操作信息
function c43476205.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断当前回合是否为效果发动者回合
	if Duel.GetTurnPlayer()==tp then
		if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c43476205.filter1(chkc,e,tp) end
		-- 检查是否存在满足条件的自己场上的怪兽作为对象
		if chk==0 then return Duel.IsExistingTarget(c43476205.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 提示玩家选择效果对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 选择满足条件的自己场上的怪兽作为对象
		Duel.SelectTarget(tp,c43476205.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	else
		if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c43476205.filter2(chkc,e,tp) end
		-- 检查是否存在满足条件的对方场上的怪兽作为对象
		if chk==0 then return Duel.IsExistingTarget(c43476205.filter2,tp,0,LOCATION_MZONE,1,nil,e,tp) end
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_CONTROL)
		-- 提示玩家选择效果对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 选择满足条件的对方场上的怪兽作为对象
		local g=Duel.SelectTarget(tp,c43476205.filter2,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
		-- 设置操作信息，记录将要改变控制权的怪兽
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	end
	-- 设置操作信息，记录将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理函数，根据回合玩家决定是否改变控制权并特殊召唤怪兽
function c43476205.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	-- 判断当前回合是否为效果发动者回合
	if Duel.GetTurnPlayer()~=tp then
		if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
		-- 尝试将目标怪兽的控制权交给发动者
		if Duel.GetControl(tc,tp)==0 then return end
		-- 中断当前效果，使后续处理视为错时点
		Duel.BreakEffect()
	end
	-- 检查目标怪兽是否必须作为超量素材
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c43476205.filter3,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将目标怪兽的叠放卡叠放到特殊召唤的怪兽上
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将目标怪兽叠放到特殊召唤的怪兽上
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将特殊召唤的怪兽以超量召唤方式特殊召唤到场上
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
