--突然進化
-- 效果：
-- 把自己场上1只爬虫类族怪兽解放才能发动。从卡组把1只名字带有「进化龙」的怪兽特殊召唤。
function c24362891.initial_effect(c)
	-- 创建效果，设置为发动时点，可特殊召唤，发动时需支付解放1只爬虫类族怪兽的代价
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c24362891.cost)
	e1:SetTarget(c24362891.target)
	e1:SetOperation(c24362891.operation)
	c:RegisterEffect(e1)
end
-- 支付发动代价，检查并选择1只可解放的爬虫类族怪兽进行解放
function c24362891.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 检查玩家场上是否存在至少1张满足条件的爬虫类族怪兽可被解放
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,nil,RACE_REPTILE) end
	-- 选择1张满足条件的爬虫类族怪兽作为解放对象
	local g=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,nil,RACE_REPTILE)
	-- 以支付代价的方式解放所选的怪兽
	Duel.Release(g,REASON_COST)
end
-- 过滤函数，用于筛选名字带有「进化龙」的怪兽且可特殊召唤
function c24362891.filter(c,e,tp)
	return c:IsSetCard(0x604e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标，检查卡组中是否存在满足条件的怪兽并准备特殊召唤
function c24362891.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 若场上没有空位则无法发动效果
		if e:GetLabel()==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		e:SetLabel(0)
		-- 检查卡组中是否存在至少1张名字带有「进化龙」且可特殊召唤的怪兽
		return Duel.IsExistingMatchingCard(c24362891.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	e:SetLabel(0)
	-- 设置连锁操作信息，表示将要特殊召唤1张名字带有「进化龙」的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行效果处理，从卡组选择1只名字带有「进化龙」的怪兽特殊召唤
function c24362891.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若场上没有空位则无法发动效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只名字带有「进化龙」且可特殊召唤的怪兽
	local g=Duel.SelectMatchingCard(tp,c24362891.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 将所选怪兽正面表示特殊召唤到场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
