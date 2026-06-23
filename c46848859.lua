--ネイビィロイド
-- 效果：
-- 对方以自己场上的魔法·陷阱卡为对象把持有使场上的魔法·陷阱卡破坏效果的卡发动时，可以丢弃1张手卡，那张卡的发动和效果无效并破坏。
function c46848859.initial_effect(c)
	-- 创建效果，设置效果描述为“无效并破坏”，分类为无效和破坏，类型为诱发即时效果，触发时机为连锁发动，属性为伤害步骤和伤害计算时可发动，发动位置为主怪兽区，条件函数为c46848859.condition，费用函数为c46848859.cost，目标函数为c46848859.target，效果处理函数为c46848859.operation
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46848859,0))  --"无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c46848859.condition)
	e1:SetCost(c46848859.cost)
	e1:SetTarget(c46848859.target)
	e1:SetOperation(c46848859.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查卡片是否在场上且为魔法或陷阱类型
function c46848859.cfilter(c)
	return c:IsOnField() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 过滤函数：检查卡片是否在场上且控制者为指定玩家且为魔法或陷阱类型
function c46848859.tgfilter(c,tp)
	return c:IsOnField() and c:IsControler(tp) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 条件函数：判断是否满足发动条件，包括自身未被战斗破坏、连锁可被无效、效果具有取对象属性、目标卡组中存在己方魔法/陷阱卡、不与发动的魔法卡冲突等
function c46848859.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自身处于战斗破坏状态或连锁不可无效，则返回false
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取连锁的攻击对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsExists(c46848859.tgfilter,1,nil,tp) then return false end
	if re:IsHasCategory(CATEGORY_NEGATE)
		-- 如果该连锁具有CATEGORY_NEGATE且上一个连锁的效果类型为EFFECT_TYPE_ACTIVATE，则返回false
		and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 获取连锁中涉及破坏效果的信息
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(c46848859.cfilter,nil)-tg:GetCount()>0
end
-- 费用函数：检查是否可以丢弃1张手牌作为发动代价，并执行丢弃操作
function c46848859.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌中是否存在可丢弃的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家丢弃1张手牌，原因包括代价和丢弃
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 目标函数：设置连锁处理时的操作信息，包括无效和破坏
function c46848859.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为无效效果
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息为破坏效果
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理函数：使连锁发动无效并破坏对象卡
function c46848859.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果连锁发动无效且对象卡有效，则进行破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因破坏目标卡组中的卡片
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
