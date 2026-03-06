--溟界の蛇睡蓮
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只爬虫类族怪兽送去墓地。那之后，自己墓地有爬虫类族怪兽5种类以上存在的场合，可以从自己墓地把1只爬虫类族怪兽特殊召唤。
function c24050692.initial_effect(c)
	-- ①：从卡组把1只爬虫类族怪兽送去墓地。那之后，自己墓地有爬虫类族怪兽5种类以上存在的场合，可以从自己墓地把1只爬虫类族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,24050692+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c24050692.target)
	e1:SetOperation(c24050692.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选可以送去墓地的爬虫类族怪兽
function c24050692.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_REPTILE) and c:IsAbleToGrave()
end
-- 效果处理时的判断条件，检查是否能从卡组选择1只爬虫类族怪兽送去墓地
function c24050692.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否能从卡组选择1只爬虫类族怪兽送去墓地
	if chk==0 then return Duel.IsExistingMatchingCard(c24050692.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时将要送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数，用于筛选爬虫类族怪兽
function c24050692.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_REPTILE)
end
-- 过滤函数，用于筛选可以特殊召唤的爬虫类族怪兽
function c24050692.spfilter(c,e,tp)
	return c24050692.cfilter(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理函数，执行将卡从卡组送去墓地并可能特殊召唤的操作
function c24050692.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1只爬虫类族怪兽送去墓地
	local g=Duel.SelectMatchingCard(tp,c24050692.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 确认选择的卡已成功送去墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0
		-- 确认送去墓地的卡在墓地
		and Duel.GetOperatedGroup():GetFirst():IsLocation(LOCATION_GRAVE)
		-- 确认玩家场上存在空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认玩家墓地有5种类以上的爬虫类族怪兽
		and Duel.GetMatchingGroup(c24050692.cfilter,tp,LOCATION_GRAVE,0,nil):GetClassCount(Card.GetCode)>=5
		-- 确认玩家墓地存在可特殊召唤的爬虫类族怪兽
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c24050692.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 询问玩家是否选择特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(24050692,0)) then  --"是否选怪兽特殊召唤？"
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从墓地选择1只爬虫类族怪兽进行特殊召唤
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c24050692.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 将选择的卡特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
