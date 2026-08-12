--光波双顎機
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：从额外卡组特殊召唤的怪兽在对方场上存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：丢弃1张手卡才能发动。从手卡·卡组把1只「光波」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是「光波」怪兽不能特殊召唤。
function c21999001.initial_effect(c)
	-- ①：从额外卡组特殊召唤的怪兽在对方场上存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c21999001.sprcon)
	c:RegisterEffect(e1)
	-- ②：丢弃1张手卡才能发动。从手卡·卡组把1只「光波」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是「光波」怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21999001,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,21999001)
	e2:SetCost(c21999001.spcost)
	e2:SetTarget(c21999001.sptg)
	e2:SetOperation(c21999001.spop)
	c:RegisterEffect(e2)
end
-- 判断是否满足手卡特殊召唤的条件，即自己场上没有怪兽，对方场上存在从额外卡组特殊召唤的怪兽，且自己场上存在召唤区域。
function c21999001.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否没有怪兽。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 检查对方场上是否存在从额外卡组特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(Card.IsSummonLocation,tp,0,LOCATION_MZONE,1,nil,LOCATION_EXTRA)
		-- 检查自己场上是否存在召唤区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 用于判断手牌是否可以被丢弃并满足特殊召唤条件的过滤函数。
function c21999001.costfilter(c,e,tp)
	-- 判断手牌是否可以被丢弃，并且自己场上有「光波」怪兽可以特殊召唤。
	return c:IsDiscardable() and Duel.IsExistingMatchingCard(c21999001.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,c,e,tp)
end
-- 用于判断是否可以特殊召唤的过滤函数，检查是否为「光波」怪兽且可以特殊召唤。
function c21999001.spfilter(c,e,tp)
	return c:IsSetCard(0xe5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果发动时的丢弃手牌成本。
function c21999001.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 设置效果的发动条件和处理流程，包括是否满足丢弃手牌条件、选择特殊召唤目标等。
function c21999001.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查是否还有召唤区域可以特殊召唤怪兽。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		if e:GetLabel()~=0 then
			e:SetLabel(0)
			-- 检查是否存在可以丢弃的手牌并满足特殊召唤条件。
			return Duel.IsExistingMatchingCard(c21999001.costfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		else
			-- 检查是否存在可以特殊召唤的「光波」怪兽。
			return Duel.IsExistingMatchingCard(c21999001.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
		end
	end
	if e:GetLabel()~=0 then
		e:SetLabel(0)
		-- 提示玩家选择要丢弃的手牌。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 选择要丢弃的手牌。
		local g=Duel.SelectMatchingCard(tp,c21999001.costfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		-- 将选中的手牌送去墓地作为发动代价。
		Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	end
	-- 设置效果处理信息，表示将要特殊召唤「光波」怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 处理效果发动后的操作，包括选择并特殊召唤「光波」怪兽，以及设置不能特殊召唤非「光波」怪兽的效果。
function c21999001.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否还有召唤区域可以特殊召唤怪兽。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的「光波」怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择要特殊召唤的「光波」怪兽。
		local g=Duel.SelectMatchingCard(tp,c21999001.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的「光波」怪兽特殊召唤到场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 设置发动后直到回合结束时自己不能特殊召唤非「光波」怪兽的效果。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c21999001.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能特殊召唤的效果注册到场上。
	Duel.RegisterEffect(e1,tp)
end
-- 设置不能特殊召唤非「光波」怪兽的判断条件。
function c21999001.splimit(e,c)
	return not c:IsSetCard(0xe5)
end
