--エクシーズ・リフレクト
-- 效果：
-- 场上的超量怪兽为对象的效果怪兽的效果·魔法·陷阱卡的发动无效并破坏。那之后，给与对方基本分800分伤害。
function c2371506.initial_effect(c)
	-- 效果原文：场上的超量怪兽为对象的效果怪兽的效果·魔法·陷阱卡的发动无效并破坏。那之后，给与对方基本分800分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c2371506.condition)
	e1:SetTarget(c2371506.target)
	e1:SetOperation(c2371506.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查目标怪兽是否为超量怪兽
function c2371506.cfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 效果作用：判断连锁发动是否为取对象效果且为怪兽效果或魔法/陷阱效果，并确认连锁对象包含超量怪兽，且该连锁可被无效
function c2371506.condition(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	if not re:IsActiveType(TYPE_MONSTER) and not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 效果作用：获取连锁的发动对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 效果作用：判断对象卡片组中是否存在超量怪兽且该连锁可被无效
	return tg and tg:IsExists(c2371506.cfilter,1,nil) and Duel.IsChainNegatable(ev)
end
-- 效果作用：设置连锁处理时的操作信息，包括使发动无效、破坏对象卡片和给予对方基本分伤害
function c2371506.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：设置连锁处理时的操作信息，使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 效果作用：设置连锁处理时的操作信息，破坏对象卡片
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	-- 效果作用：设置连锁处理时的操作信息，给予对方基本分800伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 效果作用：执行连锁处理，先无效发动并破坏对象卡片，再给予对方基本分伤害
function c2371506.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断是否成功使连锁发动无效且对象卡片存在并关联到该效果
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 效果作用：破坏对象卡片
		Duel.Destroy(eg,REASON_EFFECT)
	end
	-- 效果作用：中断当前效果处理，使后续效果视为不同时处理
	Duel.BreakEffect()
	-- 效果作用：给予对方基本分800伤害
	Duel.Damage(1-tp,800,REASON_EFFECT)
end
