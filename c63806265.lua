--虹の引力
-- 效果：
-- 自己的场上以及墓地名字带有「宝玉兽」的卡合计7种类存在的场合才能发动。把自己的卡组或者墓地存在的1只名字带有「究极宝玉神」的怪兽无视召唤条件特殊召唤。
function c63806265.initial_effect(c)
	-- 自己的场上以及墓地名字带有「宝玉兽」的卡合计7种类存在的场合才能发动。把自己的卡组或者墓地存在的1只名字带有「究极宝玉神」的怪兽无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(c63806265.condition)
	e1:SetTarget(c63806265.target)
	e1:SetOperation(c63806265.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：过滤出自己场上表侧表示以及墓地中名字带有「宝玉兽」的卡。
function c63806265.cfilter(c)
	return c:IsSetCard(0x1034) and (not c:IsOnField() or c:IsFaceup())
end
-- 发动条件：检查自己场上和墓地的「宝玉兽」卡片合计是否有7种类以上。
function c63806265.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上及墓地中所有满足条件的「宝玉兽」卡片。
	local g=Duel.GetMatchingGroup(c63806265.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	return ct>6
end
-- 过滤函数：过滤出卡组或墓地中可以无视召唤条件特殊召唤的「究极宝玉神」怪兽。
function c63806265.filter(c,e,tp)
	return c:IsSetCard(0x2034) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果发动靶向：检查怪兽区域是否有空位，以及卡组或墓地中是否存在可特殊召唤的「究极宝玉神」怪兽，并设置操作信息。
function c63806265.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可以特殊召唤怪兽的空余怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的卡组或墓地中是否存在至少1只满足特殊召唤条件的「究极宝玉神」怪兽。
		and Duel.IsExistingMatchingCard(c63806265.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁的操作信息，表示该效果包含从卡组或墓地特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：在怪兽区域有空位的情况下，从卡组或墓地选择1只「究极宝玉神」怪兽无视召唤条件特殊召唤。
function c63806265.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否还有空位，若无则不处理效果。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组或墓地中选择1只满足条件的「究极宝玉神」怪兽（受「王家之谷」影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c63806265.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽无视召唤条件以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
