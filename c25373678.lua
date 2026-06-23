--旋風のボルテクス
-- 效果：
-- 调整＋调整以外的鸟兽族怪兽1只以上
-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把1只4星以下的鸟兽族怪兽特殊召唤。
function c25373678.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求1只调整和1只调整以外的鸟兽族怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_WINDBEAST),1)
	c:EnableReviveLimit()
	-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把1只4星以下的鸟兽族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25373678,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c25373678.condition)
	e1:SetTarget(c25373678.target)
	e1:SetOperation(c25373678.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：卡片在墓地且因战斗破坏
function c25373678.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤满足条件的怪兽：等级4以下、鸟兽族、可特殊召唤
function c25373678.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_WINDBEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动检查：场上存在空位且卡组存在满足条件的怪兽
function c25373678.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c25373678.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息，确定将要特殊召唤的怪兽数量和位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：若场上存在空位则提示选择并特殊召唤满足条件的怪兽
function c25373678.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c25373678.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
