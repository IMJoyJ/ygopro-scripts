--牛頭鬼
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从卡组把1只不死族怪兽送去墓地。
-- ②：这张卡被送去墓地的场合，从自己墓地把「牛头鬼」以外的1只不死族怪兽除外才能发动。从手卡把1只不死族怪兽特殊召唤。
function c52467217.initial_effect(c)
	-- ①：自己主要阶段才能发动。从卡组把1只不死族怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52467217,0))  --"卡组不死族怪兽送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,52467217)
	e1:SetTarget(c52467217.tgtg)
	e1:SetOperation(c52467217.tgop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合，从自己墓地把「牛头鬼」以外的1只不死族怪兽除外才能发动。从手卡把1只不死族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52467217,1))  --"手卡不死族怪兽特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,52467218)
	e2:SetCost(c52467217.spcost)
	e2:SetTarget(c52467217.sptg)
	e2:SetOperation(c52467217.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选可以送去墓地的不死族怪兽
function c52467217.tgfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToGrave()
end
-- 效果处理时检查是否满足条件并设置操作信息
function c52467217.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c52467217.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将要送去墓地的卡的信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，选择并执行将卡送去墓地的操作
function c52467217.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c52467217.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤函数，用于筛选可以除外的不死族怪兽（排除牛头鬼）
function c52467217.cfilter(c)
	return c:IsRace(RACE_ZOMBIE) and not c:IsCode(52467217) and c:IsAbleToRemoveAsCost()
end
-- 效果处理函数，选择并执行将卡除外作为代价的操作
function c52467217.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c52467217.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c52467217.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数，用于筛选可以特殊召唤的不死族怪兽
function c52467217.spfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时检查是否满足条件并设置操作信息
function c52467217.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的位置进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌中是否存在满足条件的卡
		and Duel.IsExistingMatchingCard(c52467217.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置将要特殊召唤的卡的信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数，选择并执行将卡特殊召唤的操作
function c52467217.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的位置进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c52467217.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
