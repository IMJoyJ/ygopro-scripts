--ガスタ・ファルコ
-- 效果：
-- 场上表侧表示存在的这张卡被战斗以外送去墓地时，可以从自己卡组把1只名字带有「薰风」的怪兽里侧守备表示特殊召唤。
function c46044841.initial_effect(c)
	-- 诱发选发效果，满足条件时可以从自己卡组把1只名字带有「薰风」的怪兽里侧守备表示特殊召唤。
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
-- 场上表侧表示存在的这张卡被战斗以外送去墓地时才能发动。
function c46044841.condition(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_BATTLE)==0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():IsPreviousPosition(POS_FACEUP)
end
-- 过滤名字带有「薰风」的怪兽，且该怪兽可以里侧守备表示特殊召唤。
function c46044841.filter(c,e,tp)
	return c:IsSetCard(0x10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 检查是否满足特殊召唤条件，包括场上有空位和卡组中有符合条件的怪兽。
function c46044841.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认卡组中存在至少1只名字带有「薰风」且可特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c46044841.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤流程，包括选择目标怪兽并进行特殊召唤和确认。
function c46044841.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若场上没有空位则不执行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只符合条件的怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c46044841.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以里侧守备表示特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 向对方确认被特殊召唤的怪兽卡片信息。
		Duel.ConfirmCards(1-tp,g)
	end
end
