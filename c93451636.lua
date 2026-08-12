--ゼンマイハニー
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从卡组把1只4星以下的名字带有「发条」的怪兽特殊召唤。
function c93451636.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以从卡组把1只4星以下的名字带有「发条」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93451636,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c93451636.condition)
	e1:SetTarget(c93451636.target)
	e1:SetOperation(c93451636.operation)
	c:RegisterEffect(e1)
end
-- 检查自身是否被战斗破坏并送去墓地
function c93451636.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤卡组中等级4以下、名字带有「发条」且可以特殊召唤的怪兽
function c93451636.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x58) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标，在发动阶段检查自身场上是否有空位以及卡组中是否存在符合条件的怪兽
function c93451636.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c93451636.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示该效果会从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数，从卡组选择1只符合条件的「发条」怪兽特殊召唤到场上
function c93451636.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c93451636.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
