--A・O・J サイクロン・クリエイター
-- 效果：
-- 1回合1次，丢弃1张手卡才能发动。选场上的调整数量的场上的魔法·陷阱卡回到持有者手卡。
function c45586855.initial_effect(c)
	-- 效果原文内容：1回合1次，丢弃1张手卡才能发动。选场上的调整数量的场上的魔法·陷阱卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45586855,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c45586855.cost)
	e1:SetTarget(c45586855.target)
	e1:SetOperation(c45586855.operation)
	c:RegisterEffect(e1)
end
-- 规则层面作用：检查是否可以丢弃1张手卡作为发动代价
function c45586855.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：判断玩家手牌中是否存在可丢弃的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 规则层面作用：执行丢弃1张手卡的操作，作为效果发动的代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 规则层面作用：定义调整怪兽的筛选条件
function c45586855.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TUNER)
end
-- 规则层面作用：定义魔法·陷阱卡的筛选条件
function c45586855.rfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 规则层面作用：设置效果的目标选择逻辑，确定需要选择的魔法·陷阱卡数量
function c45586855.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：计算场上满足条件的调整怪兽数量
	local ct=Duel.GetMatchingGroupCount(c45586855.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 规则层面作用：判断场上是否存在满足条件的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c45586855.rfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,nil) end
	-- 规则层面作用：获取满足条件的魔法·陷阱卡组
	local rg=Duel.GetMatchingGroup(c45586855.rfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 规则层面作用：设置连锁操作信息，指定将要处理的卡牌数量和类型
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,rg,ct,0,0)
end
-- 规则层面作用：执行效果的处理流程，包括选择并返回魔法·陷阱卡到手牌
function c45586855.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：再次计算场上满足条件的调整怪兽数量
	local ct=Duel.GetMatchingGroupCount(c45586855.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 规则层面作用：再次获取满足条件的魔法·陷阱卡组
	local rg=Duel.GetMatchingGroup(c45586855.rfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if rg:GetCount()<ct then return end
	-- 规则层面作用：提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local sg=rg:Select(tp,ct,ct,nil)
	-- 规则层面作用：显示所选卡牌被选为对象的动画效果
	Duel.HintSelection(sg)
	-- 规则层面作用：将选中的卡牌送回持有者手牌
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
end
