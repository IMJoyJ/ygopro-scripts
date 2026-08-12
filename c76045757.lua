--身代わりの闇
-- 效果：
-- ①：要让场上的卡破坏的魔法·陷阱·怪兽的效果由对方发动时才能发动。那个效果无效。那之后，从卡组把1只3星以下的暗属性怪兽送去墓地。
function c76045757.initial_effect(c)
	-- ①：要让场上的卡破坏的魔法·陷阱·怪兽的效果由对方发动时才能发动。那个效果无效。那之后，从卡组把1只3星以下的暗属性怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c76045757.condition)
	e1:SetTarget(c76045757.target)
	e1:SetOperation(c76045757.operation)
	c:RegisterEffect(e1)
end
-- 发动条件：检查是否为对方发动的且可以被无效的效果连锁
function c76045757.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查发动效果的玩家是否为对方，且该连锁效果是否可以被无效
	if not (ep==1-tp and Duel.IsChainDisablable(ev)) then return false end
	if re:IsHasCategory(CATEGORY_NEGATE)
		-- 检查前一个连锁是否为魔法·陷阱卡的发动（用于排除无效发动的反击陷阱等情况）
		and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 获取当前连锁中关于破坏效果的操作信息
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(Card.IsOnField,nil)-tg:GetCount()>0
end
-- 过滤函数：卡组中等级3以下、暗属性且能送去墓地的怪兽
function c76045757.tgfilter(c)
	return c:IsLevelBelow(3) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToGrave()
end
-- 效果发动准备：检查卡组中是否存在符合条件的怪兽，并设置送去墓地和无效效果的操作信息
function c76045757.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查卡组中是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c76045757.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：使该连锁的效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果处理：无效对方的效果，之后从卡组将1只3星以下的暗属性怪兽送去墓地
function c76045757.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功无效了该效果，且此时卡组中仍存在满足条件的怪兽
	if Duel.NegateEffect(ev) and Duel.IsExistingMatchingCard(c76045757.tgfilter,tp,LOCATION_DECK,0,1,nil) then
		-- 中断当前效果处理，使后续的送去墓地处理不与无效效果同时进行（造成错时点）
		Duel.BreakEffect()
		-- 提示玩家选择要送去墓地的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家从卡组中选择1只满足过滤条件的怪兽
		local tg=Duel.SelectMatchingCard(tp,c76045757.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 将选中的怪兽因效果送去墓地
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end
