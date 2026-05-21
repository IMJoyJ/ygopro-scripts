--緊急合成
-- 效果：
-- 让自己墓地存在的1张「核成兽的钢核」回到卡组发动。从自己的手卡·墓地把1只4星以下的名字带有「核成」的怪兽特殊召唤。
function c99002135.initial_effect(c)
	-- 将「核成兽的钢核」的卡片密码注册到本卡的关联卡片列表中
	aux.AddCodeList(c,36623431)
	-- 让自己墓地存在的1张「核成兽的钢核」回到卡组发动。从自己的手卡·墓地把1只4星以下的名字带有「核成」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c99002135.cost)
	e1:SetTarget(c99002135.target)
	e1:SetOperation(c99002135.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地中可以作为代价回到卡组的「核成兽的钢核」
function c99002135.cfilter(c)
	return c:IsCode(36623431) and c:IsAbleToDeckAsCost()
end
-- 发动代价：让自己墓地存在的1张「核成兽的钢核」回到卡组
function c99002135.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己墓地是否存在可以作为代价回到卡组的「核成兽的钢核」
	if chk==0 then return Duel.IsExistingMatchingCard(c99002135.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择自己墓地存在的1张「核成兽的钢核」
	local g=Duel.SelectMatchingCard(tp,c99002135.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡片洗回卡组作为发动代价
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 过滤条件：手卡或墓地中等级4以下、名字带有「核成」且可以特殊召唤的怪兽
function c99002135.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x1d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动目标：检查怪兽区域空位以及手卡·墓地是否存在可特殊召唤的「核成」怪兽，并设置特殊召唤的操作信息
function c99002135.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动阶段，检查自己手卡或墓地是否存在至少1只满足特殊召唤条件的「核成」怪兽
		and Duel.IsExistingMatchingCard(c99002135.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理信息：从手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果处理：从自己的手卡·墓地把1只4星以下的名字带有「核成」的怪兽特殊召唤
function c99002135.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，检查自己场上是否有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或不受「王家之谷」影响的墓地中选择1只满足条件的「核成」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c99002135.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
