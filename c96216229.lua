--剣闘獣の戦車
-- 效果：
-- ①：自己场上有「剑斗兽」怪兽存在，怪兽的效果发动时才能发动。那个发动无效并破坏。
function c96216229.initial_effect(c)
	-- ①：自己场上有「剑斗兽」怪兽存在，怪兽的效果发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c96216229.condition)
	e1:SetTarget(c96216229.target)
	e1:SetOperation(c96216229.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查卡片是否为表侧表示的「剑斗兽」怪兽
function c96216229.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1019)
end
-- 发动条件：自己场上有「剑斗兽」怪兽存在，且有怪兽的效果发动，且该发动可以被无效
function c96216229.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「剑斗兽」怪兽
	return Duel.IsExistingMatchingCard(c96216229.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查当前发动的效果是否为怪兽效果，且该发动是否可以被无效
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 靶向/操作信息设置：设置无效与破坏的操作信息
function c96216229.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该怪兽效果的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该发动效果的怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使怪兽效果的发动无效并破坏
function c96216229.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功无效该效果的发动，且该卡片与该效果存在关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该发动效果的卡片
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
