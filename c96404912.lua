--無償交換
-- 效果：
-- ①：对方把怪兽的效果发动时才能发动。那个发动无效并破坏。对方从卡组抽1张。
function c96404912.initial_effect(c)
	-- ①：对方把怪兽的效果发动时才能发动。那个发动无效并破坏。对方从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c96404912.condition)
	e1:SetTarget(c96404912.target)
	e1:SetOperation(c96404912.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：对方发动怪兽效果时
function c96404912.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方发动的怪兽效果，且该连锁的发动可以被无效
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 发动准备：检查对方是否能抽卡，并设置无效、破坏、抽卡的操作信息
function c96404912.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查对方玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(1-tp,1) end
	-- 设置操作信息：使该发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若发动效果的卡可被破坏且与效果有联系，设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	-- 设置操作信息：对方抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
end
-- 效果处理：使发动无效并破坏，之后对方抽卡
function c96404912.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使发动无效，且该卡与该效果有联系
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏发动效果的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
	-- 对方从卡组抽1张卡
	Duel.Draw(1-tp,1,REASON_EFFECT)
end
