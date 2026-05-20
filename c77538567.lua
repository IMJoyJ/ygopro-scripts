--魔宮の賄賂
-- 效果：
-- ①：对方把魔法·陷阱卡发动时才能发动。那个发动无效并破坏。对方抽1张。
function c77538567.initial_effect(c)
	-- ①：对方把魔法·陷阱卡发动时才能发动。那个发动无效并破坏。对方抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c77538567.condition)
	e1:SetTarget(c77538567.target)
	e1:SetOperation(c77538567.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判断函数
function c77538567.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查触发连锁的效果是否为对方发动的魔法·陷阱卡的发动，且该发动是否可以被无效
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and rp==1-tp and Duel.IsChainNegatable(ev)
end
-- 效果发动时的目标选择与操作信息注册函数
function c77538567.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查对方玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(1-tp,1) end
	-- 设置操作信息：使触发连锁的卡的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏触发连锁的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	-- 设置操作信息：对方玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
end
-- 效果处理的执行函数
function c77538567.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使该魔法·陷阱卡的发动无效，并确认该卡在无效后是否仍与该效果存在联系
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏被无效发动的卡片
		Duel.Destroy(eg,REASON_EFFECT)
	end
	-- 让对方玩家抽1张卡
	Duel.Draw(1-tp,1,REASON_EFFECT)
end
