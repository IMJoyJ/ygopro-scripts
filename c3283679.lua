--エヴォルド・ラゴスクス
-- 效果：
-- 这张卡召唤成功时，可以从卡组把1只名字带有「进化龙」的怪兽送去墓地。此外，这张卡反转时，可以从卡组把1只名字带有「进化虫」的怪兽特殊召唤。
function c3283679.initial_effect(c)
	-- 这张卡召唤成功时，可以从卡组把1只名字带有「进化龙」的怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3283679,0))  --"送墓"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c3283679.target)
	e1:SetOperation(c3283679.operation)
	c:RegisterEffect(e1)
	-- 这张卡反转时，可以从卡组把1只名字带有「进化虫」的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3283679,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_FLIP)
	e2:SetTarget(c3283679.sptg)
	e2:SetOperation(c3283679.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选卡组中名字带有「进化龙」的怪兽
function c3283679.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x604e) and c:IsAbleToGrave()
end
-- 检查是否满足送墓效果的发动条件
function c3283679.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有满足条件的「进化龙」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c3283679.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置送墓效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 送墓效果的处理函数
function c3283679.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c3283679.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤函数，用于筛选卡组中名字带有「进化虫」的怪兽
function c3283679.spfilter(c,e,tp)
	return c:IsSetCard(0x304e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查是否满足特殊召唤效果的发动条件
function c3283679.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否有满足条件的「进化虫」怪兽
		and Duel.IsExistingMatchingCard(c3283679.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的处理函数
function c3283679.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c3283679.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
