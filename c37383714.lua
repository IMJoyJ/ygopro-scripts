--魂の綱
-- 效果：
-- ①：自己场上的怪兽被效果破坏送去墓地时，支付1000基本分才能发动。从卡组把1只4星怪兽特殊召唤。
function c37383714.initial_effect(c)
	-- 效果原文内容：①：自己场上的怪兽被效果破坏送去墓地时，支付1000基本分才能发动。从卡组把1只4星怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c37383714.condition)
	e1:SetCost(c37383714.cost)
	e1:SetTarget(c37383714.target)
	e1:SetOperation(c37383714.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查被破坏的怪兽是否为效果破坏且在自己场上被破坏的怪兽
function c37383714.cfilter(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsReason(REASON_DESTROY) and c:IsType(TYPE_MONSTER)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 效果作用：判断是否有满足条件的怪兽被破坏送入墓地
function c37383714.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c37383714.cfilter,1,nil,tp)
end
-- 效果作用：支付1000基本分
function c37383714.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 效果作用：支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 效果作用：过滤卡组中4星且能特殊召唤的怪兽
function c37383714.spfilter(c,e,tp)
	return c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：判断是否满足特殊召唤条件
function c37383714.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：判断卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c37383714.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 效果作用：设置连锁操作信息，提示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：执行特殊召唤操作
function c37383714.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果作用：提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c37383714.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 效果作用：将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
