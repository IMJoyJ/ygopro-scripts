--ダイスインパクト
-- 效果：
-- 对方发动的掷骰子效果的发动无效，那张卡破坏。
function c59905358.initial_effect(c)
	-- 对方发动的掷骰子效果的发动无效，那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c59905358.condition)
	e1:SetTarget(c59905358.target)
	e1:SetOperation(c59905358.activate)
	c:RegisterEffect(e1)
end
-- 过滤发动条件：检查触发的连锁是否为可被无效的、且包含掷骰子效果的怪兽效果或魔陷卡的发动
function c59905358.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁的发动是否可以被无效
	if not Duel.IsChainNegatable(ev) then return false end
	if not re:IsActiveType(TYPE_MONSTER) and not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 获取当前连锁的操作信息，检查其是否包含掷骰子效果
	local ex=Duel.GetOperationInfo(ev,CATEGORY_DICE)
	return ex
end
-- 设置效果发动的目标：声明该效果包含使发动无效和破坏卡片的操作信息
function c59905358.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使发动无效，对象为触发连锁的卡
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏，对象为触发连锁的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使该连锁的发动无效，并将其破坏
function c59905358.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使该连锁的发动无效，且该卡仍与该效果存在联系
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将触发连锁的卡因效果破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
