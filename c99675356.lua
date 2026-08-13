--紫炎の足軽
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从卡组把1只3星以下的名字带有「六武众」的怪兽特殊召唤。
function c99675356.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以从卡组把1只3星以下的名字带有「六武众」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99675356,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c99675356.condition)
	e1:SetTarget(c99675356.target)
	e1:SetOperation(c99675356.operation)
	c:RegisterEffect(e1)
end
-- 该效果的发动条件：此卡被战斗破坏后处于墓地，且破坏原因为战斗。
function c99675356.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤条件：等级3以下、名字带有「六武众」字段、并且可以被特殊召唤的怪兽。
function c99675356.filter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsSetCard(0x103d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时点检查：己方主要怪兽区有空位，且卡组中存在满足过滤条件的怪兽。
function c99675356.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区的可用空位是否大于0。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足条件的「六武众」怪兽。
		and Duel.IsExistingMatchingCard(c99675356.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次连锁的操作信息：效果处理时将进行特殊召唤，对象为卡组中的1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：若空位不足则直接终止；否则提示玩家选择要特殊召唤的卡，从卡组选出1只符合条件的怪兽并特殊召唤。
function c99675356.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果己方主要怪兽区没有可用空位，则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示特殊召唤的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的「六武众」怪兽。
	local g=Duel.SelectMatchingCard(tp,c99675356.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
