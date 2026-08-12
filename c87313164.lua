--ギョッ！
-- 效果：
-- 让从游戏中除外的1只自己的鱼族·海龙族·水族怪兽回到卡组发动。效果怪兽的效果的发动无效并破坏。
function c87313164.initial_effect(c)
	-- 让从游戏中除外的1只自己的鱼族·海龙族·水族怪兽回到卡组发动。效果怪兽的效果的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c87313164.condition)
	e1:SetCost(c87313164.cost)
	e1:SetTarget(c87313164.target)
	e1:SetOperation(c87313164.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数
function c87313164.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查触发的效果是否为怪兽效果，且该连锁的发动能否被无效
	return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 过滤条件：自己除外状态的表侧表示鱼族、海龙族或水族怪兽，且能作为代价返回卡组
function c87313164.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH+RACE_SEASERPENT+RACE_AQUA) and c:IsAbleToDeckAsCost()
end
-- 定义发动代价函数
function c87313164.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查除外区是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c87313164.cfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择1张除外区的满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c87313164.cfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 将选中的怪兽作为代价送回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 定义效果目标函数
function c87313164.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该怪兽效果的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：如果该卡可被破坏，则将其破坏
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 定义效果运行函数
function c87313164.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该效果的发动无效，且该卡仍与该效果相关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该发动效果的怪兽
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
