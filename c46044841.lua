--ガスタ・ファルコ
-- 效果：
-- 场上表侧表示存在的这张卡被战斗以外送去墓地时，可以从自己卡组把1只名字带有「薰风」的怪兽里侧守备表示特殊召唤。
function c46044841.initial_effect(c)
	-- 场上表侧表示存在的这张卡被战斗以外送去墓地时，可以从自己卡组把1只名字带有「薰风」的怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46044841,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c46044841.condition)
	e1:SetTarget(c46044841.target)
	e1:SetOperation(c46044841.operation)
	c:RegisterEffect(e1)
end
-- 发动条件判定：这张卡被送去墓地的原因不是战斗，且其之前位于场上并处于表侧表示。
function c46044841.condition(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_BATTLE)==0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():IsPreviousPosition(POS_FACEUP)
end
-- 筛选卡组中满足「薰风」字段且能够以里侧守备表示特殊召唤的怪兽。
function c46044841.filter(c,e,tp)
	return c:IsSetCard(0x10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果发动检查：在chk==0时确认自己怪兽区有空位且卡组中存在符合条件的薰风怪兽，以决定效果能否发动。
function c46044841.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可以特殊召唤怪兽的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的「薰风」怪兽。
		and Duel.IsExistingMatchingCard(c46044841.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果将进行1只怪兽的特殊召唤，候选卡来自自己卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从自己卡组选择1只符合条件的「薰风」怪兽，以里侧守备表示特殊召唤，并让对方确认。
function c46044841.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查怪兽区空位，若无空位则直接中止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1张符合条件的「薰风」怪兽。
	local g=Duel.SelectMatchingCard(tp,c46044841.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以里侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 将特殊召唤的怪兽展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
