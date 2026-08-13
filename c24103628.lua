--幻影の魔術士
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把1只攻击力1000以下的名字带有「英雄」的怪兽表侧守备表示特殊召唤。
function c24103628.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把1只攻击力1000以下的名字带有「英雄」的怪兽表侧守备表示特殊召唤。
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
-- 判断效果持有者（这张卡）确实在墓地且是被战斗破坏送去墓地，满足“被战斗破坏送去墓地时”的触发条件。
function c24103628.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 作为检索/特殊召唤的过滤条件：攻击力1000以下且名字带有「英雄」且能够被表侧守备表示特殊召唤。
function c24103628.filter(c,e,tp)
	return c:IsAttackBelow(1000) and c:IsSetCard(0x8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时检查是否满足特殊召唤条件：自己主要怪兽区有空位，且卡组中存在符合条件的「英雄」怪兽。
function c24103628.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区是否有空位，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足c24103628.filter条件的「英雄」怪兽。
		and Duel.IsExistingMatchingCard(c24103628.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次连锁将进行特殊召唤的操作信息：从卡组特殊召唤1只怪兽（由效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时，若仍有空格则提示玩家从卡组选择1只符合条件的「英雄」怪兽，表侧守备表示特殊召唤。
function c24103628.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的主要怪兽区空格，则中止处理，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给发动玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组选择1张满足条件的「英雄」怪兽（攻击力1000以下、可表侧守备特殊召唤）。
	local g=Duel.SelectMatchingCard(tp,c24103628.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧守备表示特殊召唤到自己场上，不检查召唤条件和苏生限制（因为已经通过filter确认可特殊召唤）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
