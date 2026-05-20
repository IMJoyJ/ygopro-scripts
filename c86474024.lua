--共同戦線
-- 效果：
-- 自己场上有相同等级的怪兽表侧表示2只以上存在的场合才能发动。陷阱卡的发动无效并破坏。
function c86474024.initial_effect(c)
	-- 自己场上有相同等级的怪兽表侧表示2只以上存在的场合才能发动。陷阱卡的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c86474024.condition)
	e1:SetTarget(c86474024.target)
	e1:SetOperation(c86474024.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数1：用于筛选出自身表侧表示、等级大于0，且自己场上存在另一只与其等级相同的表侧表示怪兽
function c86474024.filter1(c,tp)
	local lv1=c:GetLevel()
	-- 返回条件：卡片等级大于0、表侧表示，且自己场上存在除自身以外的、等级相同的表侧表示怪兽
	return lv1>0 and c:IsFaceup() and Duel.IsExistingMatchingCard(c86474024.filter2,tp,LOCATION_MZONE,0,1,c,lv1)
end
-- 过滤函数2：用于筛选出表侧表示且等级与指定等级相同的怪兽
function c86474024.filter2(c,lv1)
	return c:IsFaceup() and c:IsLevel(lv1)
end
-- 发动条件：被连锁的效果是陷阱卡的发动、该发动可以被无效，且自己场上存在2只以上相同等级的表侧表示怪兽
function c86474024.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查被连锁的效果是否为陷阱卡的发动，且该发动可以被无效
	return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		-- 检查自己场上是否存在满足相同等级条件的表侧表示怪兽（即存在2只以上相同等级的表侧表示怪兽）
		and Duel.IsExistingMatchingCard(c86474024.filter1,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 效果的目标：设置无效发动与破坏的操作信息
function c86474024.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该陷阱卡的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该陷阱卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果的处理：使该陷阱卡的发动无效并破坏
function c86474024.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该发动无效，且该卡与该效果存在联系
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
