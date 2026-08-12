--エクソシスター・アーメント
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，从墓地特殊召唤的怪兽不在对方场上存在的场合，不在对方回合不能发动。
-- ①：支付800基本分，以自己场上1只「救祓少女」怪兽为对象才能发动。同名卡不在自己场上存在的1只「救祓少女」超量怪兽在作为对象的自己怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
function c4408198.initial_effect(c)
	-- 效果定义：将此卡注册为发动效果，可于自由时点发动，需支付800基本分，且只能选择自己场上1只「救祓少女」怪兽作为对象，对象怪兽必须满足特定条件才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,4408198+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c4408198.cost)
	e1:SetCondition(c4408198.condition)
	e1:SetTarget(c4408198.target)
	e1:SetOperation(c4408198.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查是否有从墓地召唤的怪兽存在于对方场上。
function c4408198.checkfilter(c)
	return c:IsSummonLocation(LOCATION_GRAVE)
end
-- 发动条件：若对方场上存在从墓地召唤的怪兽则可发动；否则只能在自己回合发动。
function c4408198.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在从墓地召唤的怪兽。
	if Duel.IsExistingMatchingCard(c4408198.checkfilter,tp,0,LOCATION_MZONE,1,nil) then return true end
	-- 若对方场上不存在从墓地召唤的怪兽，则只能在自己回合发动。
	return Duel.GetTurnPlayer()~=tp
end
-- 支付费用：检查并支付800基本分。
function c4408198.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付800基本分。
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 支付800基本分。
	Duel.PayLPCost(tp,800)
end
-- 过滤函数：检查场上是否存在指定编号的「救祓少女」怪兽。
function c4408198.cfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 过滤函数：选择自己场上满足条件的「救祓少女」怪兽，该怪兽需能作为超量素材且额外卡组存在符合条件的超量怪兽。
function c4408198.spfilter1(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x172)
		-- 检查额外卡组是否存在符合条件的超量怪兽。
		and Duel.IsExistingMatchingCard(c4408198.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
		-- 检查目标怪兽是否满足作为超量素材的条件。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 过滤函数：选择额外卡组中符合条件的「救祓少女」超量怪兽，该怪兽需能被特殊召唤且未在场上存在同名卡。
function c4408198.spfilter2(c,e,tp,mc)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x172) and mc:IsCanBeXyzMaterial(c)
		-- 检查目标超量怪兽是否能被特殊召唤且场上空位足够。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
		-- 检查场上是否存在同名卡。
		and not Duel.IsExistingMatchingCard(c4408198.cfilter,tp,LOCATION_ONFIELD,0,1,nil,c:GetCode())
end
-- 设置效果目标：选择自己场上满足条件的「救祓少女」怪兽作为对象，并设置操作信息。
function c4408198.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c4408198.spfilter1(chkc,e,tp) end
	-- 检查是否存在满足条件的怪兽作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c4408198.spfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的怪兽作为效果对象。
	Duel.SelectTarget(tp,c4408198.spfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息：表示将从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：获取目标怪兽，检查其是否满足超量素材条件，选择额外卡组中的超量怪兽进行特殊召唤。
function c4408198.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否满足作为超量素材的条件。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的超量怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择满足条件的超量怪兽。
	local g=Duel.SelectMatchingCard(tp,c4408198.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将目标怪兽的叠放卡叠放到召唤的超量怪兽上。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将目标怪兽叠放到召唤的超量怪兽上。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将选定的超量怪兽以超量召唤方式特殊召唤到场上。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
