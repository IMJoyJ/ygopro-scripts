--スレイブ・エイプ
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从卡组把1只名字带有「剑斗兽」的4星以下怪兽在自己场上特殊召唤。
function c3030892.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以从卡组把1只名字带有「剑斗兽」的4星以下怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3030892,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c3030892.condition)
	e1:SetTarget(c3030892.target)
	e1:SetOperation(c3030892.operation)
	c:RegisterEffect(e1)
end
-- 检查效果发动的条件：此卡是否在墓地且是被战斗破坏送去墓地。
function c3030892.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 定义可特殊召唤的怪兽的过滤条件：等级4以下、名字带有「剑斗兽」且能够被特殊召唤。
function c3030892.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时检查自己主要怪兽区是否有空位，且卡组中是否存在符合条件的怪兽。
function c3030892.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只符合条件的怪兽。
		and Duel.IsExistingMatchingCard(c3030892.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次效果的操作信息：从卡组将1只怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的操作：选择符合条件的怪兽并特殊召唤。
function c3030892.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己主要怪兽区有空位，若没有则中止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择特殊召唤怪兽的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只符合条件的怪兽。
	local g = Duel.SelectMatchingCard(tp,c3030892.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
