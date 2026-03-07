--パンダボーグ
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以支付800基本分从自己卡组把1只4星的念动力族怪兽特殊召唤。
function c39091951.initial_effect(c)
	-- 诱发选发效果，对应一速的【……才能发动】
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39091951,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c39091951.condition)
	e1:SetCost(c39091951.cost)
	e1:SetTarget(c39091951.target)
	e1:SetOperation(c39091951.operation)
	c:RegisterEffect(e1)
end
-- 这张卡被战斗破坏送去墓地时
function c39091951.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 支付800基本分
function c39091951.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付800基本分
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 让玩家支付800基本分
	Duel.PayLPCost(tp,800)
end
-- 过滤函数，用于筛选4星的念动力族可以特殊召唤的怪兽
function c39091951.filter(c,e,tp)
	return c:IsLevel(4) and c:IsRace(RACE_PSYCHO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果发动时的条件，检查场上是否有空位且卡组是否存在符合条件的怪兽
function c39091951.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家卡组是否存在至少1只满足条件的怪兽
		and Duel.IsExistingMatchingCard(c39091951.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理时的操作信息，确定要特殊召唤的卡的数量和位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理函数，检查场上是否有空位并选择怪兽进行特殊召唤
function c39091951.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c39091951.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
