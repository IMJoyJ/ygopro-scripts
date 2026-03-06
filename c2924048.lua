--借カラクリ整備蔵
-- 效果：
-- 自己场上有名字带有「机巧」的怪兽表侧守备表示存在的场合才能发动。对方发动的魔法·陷阱卡的发动无效并破坏。
function c2924048.initial_effect(c)
	-- 效果原文：自己场上有名字带有「机巧」的怪兽表侧守备表示存在的场合才能发动。对方发动的魔法·陷阱卡的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c2924048.condition)
	e1:SetTarget(c2924048.target)
	e1:SetOperation(c2924048.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查场上是否存在表侧守备表示的「机巧」怪兽
function c2924048.cfilter(c)
	return c:IsPosition(POS_FACEUP_DEFENSE) and c:IsSetCard(0x11)
end
-- 效果条件函数，判断是否满足发动条件
function c2924048.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方是否为发动者或场上是否存在符合条件的「机巧」怪兽
	if ep==tp or not Duel.IsExistingMatchingCard(c2924048.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	-- 检查对方发动的是否为魔法·陷阱卡且该连锁可以被无效
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 效果目标设定函数，设置连锁处理时的分类信息
function c2924048.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理分类为无效效果
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁处理分类为破坏效果
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果发动函数，执行效果的处理逻辑
function c2924048.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使连锁无效且目标卡仍存在于场上
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将对方发动的魔法·陷阱卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
