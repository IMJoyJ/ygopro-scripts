--聖なる煌炎
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方把魔法·陷阱·怪兽的效果发动时，让自己场上1只龙族·光属性·7星怪兽回到持有者手卡才能发动。那个效果无效并破坏。
function c58374502.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：对方把魔法·陷阱·怪兽的效果发动时，让自己场上1只龙族·光属性·7星怪兽回到持有者手卡才能发动。那个效果无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58374502,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,58374502+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c58374502.condition)
	e1:SetCost(c58374502.cost)
	e1:SetTarget(c58374502.target)
	e1:SetOperation(c58374502.activate)
	c:RegisterEffect(e1)
end
-- 设置发动条件：对方发动魔法·陷阱·怪兽的效果，且该效果可以被无效
function c58374502.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查发动效果的玩家是否为对方，且该连锁效果是否可以被无效
	return ep==1-tp and Duel.IsChainDisablable(ev)
end
-- 过滤条件：自己场上表侧表示的龙族·光属性·7星且能返回手牌的怪兽
function c58374502.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(7) and c:IsRace(RACE_DRAGON)
		and c:IsAbleToHandAsCost()
end
-- 设置发动代价：让自己场上1只龙族·光属性·7星怪兽回到持有者手卡
function c58374502.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查自己场上是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c58374502.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择自己场上1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c58374502.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选中的怪兽作为代价送回持有者手卡
	Duel.SendtoHand(g,nil,REASON_COST)
end
-- 设置效果的目标：设置无效与破坏的操作信息
function c58374502.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：无效该效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 设置效果处理：将那个效果无效并破坏
function c58374502.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功无效该效果，且该卡在效果处理时仍与该效果相关联
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
