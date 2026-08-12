--神の摂理
-- 效果：
-- ①：怪兽的效果·魔法·陷阱卡发动时，把和那个效果相同种类（怪兽·魔法·陷阱）的1张卡从手卡丢弃才能发动。那个发动无效并破坏。
function c38891741.initial_effect(c)
	-- 创建神之摄理的发动效果，设置其为魔法卡发动时的连锁响应效果，包含无效和破坏两个处理分类
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c38891741.condition)
	e1:SetCost(c38891741.cost)
	e1:SetTarget(c38891741.target)
	e1:SetOperation(c38891741.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的条件判断函数，判断发动的卡是否为怪兽效果或魔法/陷阱卡发动，并且该连锁可以被无效
function c38891741.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 发动的卡为怪兽效果或魔法/陷阱卡发动，并且该连锁可以被无效
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 用于筛选手卡中满足类型且可丢弃的卡的过滤函数
function c38891741.cfilter(c,type)
	return c:IsType(type) and c:IsDiscardable()
end
-- 效果发动时的费用处理函数，检查是否满足丢弃手卡的条件并执行丢弃操作
function c38891741.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若玩家受到解放之阿里阿德涅等效果影响，则跳过费用检查直接返回成功
	if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DISCARD_COST_CHANGE) then return true end
	local type=bit.band(re:GetActiveType(),0x7)
	-- 检查是否满足丢弃手卡的条件，即手卡中是否存在满足类型要求的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c38891741.cfilter,tp,LOCATION_HAND,0,1,nil,type) end
	-- 执行丢弃手卡操作，丢弃1张满足类型要求的手卡
	Duel.DiscardHand(tp,c38891741.cfilter,1,1,REASON_COST+REASON_DISCARD,nil,type)
end
-- 效果发动时的目标设定函数，设置将要被无效和可能被破坏的卡
function c38891741.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将要被无效的卡，即发动该效果的卡
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置将要被破坏的卡，如果该卡存在且与效果相关则进行破坏处理
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果发动时的实际处理函数，使连锁无效并根据条件破坏对应卡
function c38891741.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试使连锁无效，如果无效失败则直接返回
	if not Duel.NegateActivation(ev) then return end
	if re:GetHandler():IsRelateToEffect(re) then
		-- 如果发动的卡与效果相关则将其破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
