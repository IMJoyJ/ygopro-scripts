--幻影の魔術士
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把1只攻击力1000以下的名字带有「英雄」的怪兽表侧守备表示特殊召唤。
function c24103628.initial_effect(c)
	-- 诱发选发效果，对应一速的【……才能发动】
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24103628,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c24103628.condition)
	e1:SetTarget(c24103628.target)
	e1:SetOperation(c24103628.operation)
	c:RegisterEffect(e1)
end
-- 这张卡被战斗破坏送去墓地时
function c24103628.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 攻击力1000以下的名字带有「英雄」的怪兽
function c24103628.filter(c,e,tp)
	return c:IsAttackBelow(1000) and c:IsSetCard(0x8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 检查场上是否有满足条件的怪兽
function c24103628.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有满足条件的怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否有满足条件的怪兽
		and Duel.IsExistingMatchingCard(c24103628.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理时要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理
function c24103628.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c24103628.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
