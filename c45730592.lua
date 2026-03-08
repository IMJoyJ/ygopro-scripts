--魔救共振撃
-- 效果：
-- ①：自己场上有「魔救」同调怪兽存在，怪兽的效果发动时才能发动。那个发动无效并破坏。
function c45730592.initial_effect(c)
	-- ①：自己场上有「魔救」同调怪兽存在，怪兽的效果发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCondition(c45730592.condition)
	e1:SetTarget(c45730592.target)
	e1:SetOperation(c45730592.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检查场上是否存在表侧表示的「魔救」同调怪兽
function c45730592.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x140) and c:IsType(TYPE_SYNCHRO)
end
-- 效果条件函数，判断是否满足发动条件
function c45730592.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的「魔救」同调怪兽
	if not Duel.IsExistingMatchingCard(c45730592.filter,tp,LOCATION_MZONE,0,1,nil) then return false end
	-- 检查连锁是否可以被无效
	if not Duel.IsChainNegatable(ev) then return false end
	return re:IsActiveType(TYPE_MONSTER)
end
-- 设置效果处理时的操作信息，包括使发动无效和破坏目标怪兽
function c45730592.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息为破坏目标怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果发动时的处理函数
function c45730592.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使连锁发动无效且目标怪兽与效果相关
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将目标怪兽因效果破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
