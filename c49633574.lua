--魔轟神オルトロ
-- 效果：
-- 把1张手卡送去墓地发动。从手卡把1只3星的名字带有「魔轰神」的怪兽特殊召唤。这个效果1回合只能使用1次。
function c49633574.initial_effect(c)
	-- 把1张手卡送去墓地发动。从手卡把1只3星的名字带有「魔轰神」的怪兽特殊召唤。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49633574,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c49633574.cost)
	e1:SetTarget(c49633574.tg)
	e1:SetOperation(c49633574.op)
	c:RegisterEffect(e1)
end
-- 定义代价筛选过滤器：用于选择“把1张手卡送去墓地”的代价卡，要求该手卡可作为代价送去墓地，且手牌中存在1只满足特殊召唤条件的「魔轰神」3星怪兽，以保证发动时有合法目标。
function c49633574.cfilter(c,e,tp)
	-- 返回真当且仅当这张手卡可以作为代价送去墓地，并且手牌中存在满足特殊召唤条件的「魔轰神」3星怪兽。
	return c:IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(c49633574.spfilter,tp,LOCATION_HAND,0,1,c,e,tp)
end
-- 定义特殊召唤对象筛选器：选择手牌中满足名字带有「魔轰神」、等级为3且能够被当前效果特殊召唤的怪兽。
function c49633574.spfilter(c,e,tp)
	return c:IsSetCard(0x35) and c:IsLevel(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动代价函数：在发动时确认手牌中有可送墓的代价卡，并选择1张手卡送去墓地作为发动代价。
function c49633574.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检查阶段（chk==0），确认手牌中存在可以作为代价送去墓地且能保证后续有可特殊召唤目标的卡，否则无法支付代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c49633574.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 向操作玩家显示“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手牌中选择1张满足 cfilter 条件的卡作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c49633574.cfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选择的卡以“代价”（REASON_COST）的原因送去墓地，完成发动代价的支付。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义效果发动时的目标函数：确认己方主要怪兽区有空位，并设置效果操作信息为从手牌特殊召唤1只怪兽。
function c49633574.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在目标检查阶段（chk==0），确认己方主要怪兽区存在可用空格，确保能够进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 设置操作信息：本次效果处理时将从手牌特殊召唤1只怪兽（不取对象，数量1，位置为手牌），用于连锁判定和相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 定义效果处理函数：效果处理时若主要怪兽区仍有空位，则选择1只满足条件的「魔轰神」3星怪兽从手牌特殊召唤。
function c49633574.op(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查己方主要怪兽区是否有空位，若没有空位则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1只满足 spfilter 条件的「魔轰神」3星怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c49633574.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
