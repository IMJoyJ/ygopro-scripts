--アーマーブレイク
-- 效果：
-- 使装备魔法卡的发动无效，并且将其破坏。
function c79649195.initial_effect(c)
	-- 使装备魔法卡的发动无效，并且将其破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c79649195.condition)
	e1:SetTarget(c79649195.target)
	e1:SetOperation(c79649195.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数，用于判断是否满足发动该卡的时机
function c79649195.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查触发连锁的效果是否为装备魔法卡的发动，且该发动是否可以被无效
	return re:IsActiveType(TYPE_EQUIP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 定义效果的目标处理函数，用于进行发动的合法性检查并设置操作信息
function c79649195.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表明此效果的处理包含使发动无效，目标为触发连锁的卡片
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息，表明此效果的处理包含破坏，目标为触发连锁的卡片
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 定义效果的运行空间函数，执行无效并破坏的具体处理
function c79649195.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试使该连锁的发动无效，并检查该卡片是否仍与该效果存在联系
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 因效果将该装备魔法卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
