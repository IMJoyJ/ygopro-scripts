--ドラゴンの宝珠
-- 效果：
-- 丢弃1张手卡。以1只表侧表示的龙族怪兽作对象的陷阱卡的效果无效并破坏。
function c92408984.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 丢弃1张手卡。以1只表侧表示的龙族怪兽作对象的陷阱卡的效果无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92408984,0))  --"效果无效并破坏"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(c92408984.condition)
	e2:SetCost(c92408984.cost)
	e2:SetTarget(c92408984.target)
	e2:SetOperation(c92408984.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：位于怪兽区、表侧表示且种族为龙族的卡
function c92408984.cfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
-- 发动条件：对方发动了取对象的陷阱卡，且该卡的对象中包含场上表侧表示的龙族怪兽，且该效果可以被无效
function c92408984.condition(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsActiveType(TYPE_TRAP) then return false end
	-- 获取当前连锁的效果的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not tg or not tg:IsExists(c92408984.cfilter,1,nil) then return false end
	-- 检查该连锁的效果是否可以被无效
	return Duel.IsChainNegatable(ev)
end
-- 代价处理：丢弃1张手卡
function c92408984.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查手卡中是否存在至少1张可以丢弃的卡（排除自身）
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让玩家选择并丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 目标处理：设置无效与破坏的操作信息，并为目标卡片建立效果联系
function c92408984.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该连锁的效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if eg:GetFirst():IsLocation(LOCATION_ONFIELD) then
		eg:GetFirst():CreateEffectRelation(e)
		-- 设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使该陷阱卡的效果无效并破坏
function c92408984.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果成功使该连锁的效果无效，且该卡仍与效果存在关联
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
