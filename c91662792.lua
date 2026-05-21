--ガスタ・イグル
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把1只调整以外的4星以下的名字带有「薰风」的怪兽特殊召唤。
function c91662792.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把1只调整以外的4星以下的名字带有「薰风」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91662792,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c91662792.condition)
	e1:SetTarget(c91662792.target)
	e1:SetOperation(c91662792.operation)
	c:RegisterEffect(e1)
end
-- 检查发动条件：自身因战斗破坏被送去墓地
function c91662792.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤条件：卡组中4星以下、名字带有「薰风」且非调整的可以特殊召唤的怪兽
function c91662792.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x10) and not c:IsType(TYPE_TUNER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查发动阶段的合法性：己方场上有空怪兽位，且卡组中存在至少1只满足过滤条件的怪兽
function c91662792.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方卡组是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c91662792.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只满足条件的怪兽在己方场上特殊召唤
function c91662792.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否仍有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c91662792.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
