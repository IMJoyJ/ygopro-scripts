--進化する翼
-- 效果：
-- 把自己场上存在的1只「羽翼栗子球」和2张手卡送到墓地。从手卡·卡组特殊召唤1只「羽翼栗子球 LV10」上场。
function c25573054.initial_effect(c)
	-- 创建效果并设置其分类为特殊召唤、类型为发动、代码为自由连锁、提示时点为战斗阶段开始时点、代币为cost函数、目标为target函数、效果处理为activate函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START)
	e1:SetCost(c25573054.cost)
	e1:SetTarget(c25573054.target)
	e1:SetOperation(c25573054.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，返回满足条件的「羽翼栗子球」且能作为代币送入墓地的卡
function c25573054.tgfilter(c)
	return c:IsCode(57116033) and c:IsAbleToGraveAsCost()
end
-- 过滤函数，返回满足条件的「羽翼栗子球 LV10」且能特殊召唤的卡
function c25573054.spfilter(c,e,tp)
	return c:IsCode(98585345) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 代币处理函数，检查是否满足代币条件并选择需要送入墓地的卡
function c25573054.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足特殊召唤条件的「羽翼栗子球 LV10」卡组
	local sg=Duel.GetMatchingGroup(c25573054.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
	-- 获取满足送入墓地条件的手牌
	local hg=Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,e:GetHandler())
	if chk==0 then
		if sg:GetCount()==0 then return false end
		-- 获取玩家场上可用的怪兽区域数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<-1 then return false end
		if ft==0 then
			-- 检查场上是否存在满足条件的「羽翼栗子球」
			if not Duel.IsExistingMatchingCard(c25573054.tgfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
		else
			-- 检查场上是否存在满足条件的「羽翼栗子球」
			if not Duel.IsExistingMatchingCard(c25573054.tgfilter,tp,LOCATION_ONFIELD,0,1,nil) then return false end
		end
		if sg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
			return hg:GetCount()>1
		else
			return hg:GetCount()>2
		end
	end
	local cg=nil
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft==0 then
		-- 提示玩家选择要送入墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择满足条件的「羽翼栗子球」送入墓地
		cg=Duel.SelectMatchingCard(tp,c25573054.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	else
		-- 提示玩家选择要送入墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择满足条件的「羽翼栗子球」送入墓地
		cg=Duel.SelectMatchingCard(tp,c25573054.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	end
	local ct=sg:GetCount()
	if ct>2 or sg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
		-- 提示玩家选择要送入墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=hg:Select(tp,2,2,nil)
		cg:Merge(g)
	elseif ct==1 then
		-- 提示玩家选择要送入墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=hg:Select(tp,2,2,sg:GetFirst())
		cg:Merge(g)
	else
		-- 提示玩家选择要送入墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g1=hg:Select(tp,1,1,nil)
		if sg:IsContains(g1:GetFirst()) then
			hg:Sub(sg)
		end
		-- 提示玩家选择要送入墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g2=hg:Select(tp,1,1,g1:GetFirst())
		cg:Merge(g1)
		cg:Merge(g2)
	end
	-- 将选中的卡送入墓地作为代币
	Duel.SendtoGrave(cg,REASON_COST)
end
-- 目标函数，设置效果处理时要特殊召唤的卡
function c25573054.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理时要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK+LOCATION_HAND)
end
-- 效果处理函数，从手牌或卡组特殊召唤「羽翼栗子球 LV10」
function c25573054.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有可用的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「羽翼栗子球 LV10」
	local g=Duel.SelectMatchingCard(tp,c25573054.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的「羽翼栗子球 LV10」特殊召唤上场
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
