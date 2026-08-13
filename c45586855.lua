--A・O・J サイクロン・クリエイター
-- 效果：
-- 1回合1次，丢弃1张手卡才能发动。选场上的调整数量的场上的魔法·陷阱卡回到持有者手卡。
function c45586855.initial_effect(c)
	-- 1回合1次，丢弃1张手卡才能发动。选场上的调整数量的场上的魔法·陷阱卡回到持有者手卡。
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
-- 发动效果的代价处理：丢弃1张手卡才能发动；若不能丢弃手卡则不能发动，丢弃动作在效果发动时执行。
function c45586855.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查阶段（chk==0）确认自己手牌中存在至少1张可以丢弃的手卡，作为发动代价是否满足的判定。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 实际执行丢弃1张手卡作为发动代价，丢弃原因标记为代价与丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 定义调整怪兽筛选函数：卡必须表侧表示且为调整怪兽，用于统计场上调整怪兽的数量。
function c45586855.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TUNER)
end
-- 定义可回手魔法·陷阱卡的筛选函数：卡必须为魔法·陷阱卡且能被加入手卡（不受“不能加入手卡”效果限制）。
function c45586855.rfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 发动目标的判定与操作信息设置：先计算场上调整数量ct，再检查场上是否存在至少ct张可回手魔法·陷阱卡；若满足则取得所有可回手的魔法·陷阱卡并通告引擎本效果将进行回手牌处理。
function c45586855.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算双方场上表侧表示调整怪兽的总数量ct，这个数量将作为需要选择回手的魔法·陷阱卡的数量。
	local ct=Duel.GetMatchingGroupCount(c45586855.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 在发动合法性检查阶段确认场上存在至少ct张满足可回手条件的魔法·陷阱卡，以保证效果发动时能有足够的目标。
	if chk==0 then return Duel.IsExistingMatchingCard(c45586855.rfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,nil) end
	-- 取得当前场上所有满足可回手条件的魔法·陷阱卡，作为后续操作信息中可能受影响的范围。
	local rg=Duel.GetMatchingGroup(c45586855.rfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 向引擎设置操作信息：本效果属于回手牌（CATEGORY_TOHAND），可能送回手牌的卡为rg，预计处理数量为ct（实际选择阶段再确定具体卡牌）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,rg,ct,0,0)
end
-- 效果处理阶段：重新统计调整数量ct，获取场上所有可回手魔法·陷阱卡组；若可回手卡不足ct则效果不处理；否则提示玩家选择ct张卡并送回持有者手卡，原因为效果。
function c45586855.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时重新计算场上调整怪兽的数量ct，以确定最终要选择回手的卡牌数量。
	local ct=Duel.GetMatchingGroupCount(c45586855.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 在效果处理时重新获取场上所有可回手的魔法·陷阱卡，作为本次选择的对象集合。
	local rg=Duel.GetMatchingGroup(c45586855.rfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if rg:GetCount()<ct then return end
	-- 向当前玩家发出选择提示，要求其从符合条件的卡中选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local sg=rg:Select(tp,ct,ct,nil)
	-- 为实际选中的卡显示被选为对象的动画，并将这些卡记录为本连锁的对象，便于后续处理。
	Duel.HintSelection(sg)
	-- 将选中的魔法·陷阱卡以效果原因送回其持有者的手卡，完成回手处理。
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
end
