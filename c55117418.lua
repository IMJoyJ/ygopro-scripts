--能力吸収コア
-- 效果：
-- 自己场上有名字带有「核成」的怪兽表侧表示存在，自己墓地有「核成兽的钢核」存在的场合才能发动。效果怪兽的效果的发动无效并破坏。
function c55117418.initial_effect(c)
	-- 用于记录该卡在卡片效果中记载了「核成兽的钢核」的卡名
	aux.AddCodeList(c,36623431)
	-- 自己场上有名字带有「核成」的怪兽表侧表示存在，自己墓地有「核成兽的钢核」存在的场合才能发动。效果怪兽的效果的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c55117418.condition)
	e1:SetTarget(c55117418.target)
	e1:SetOperation(c55117418.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示存在的「核成」怪兽
function c55117418.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1d)
end
-- 发动条件：满足怪兽效果发动可被无效，且自己场上有表侧表示的「核成」怪兽、墓地有「核成兽的钢核」存在
function c55117418.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁的发动是否为怪兽效果，且该发动可以被无效
	return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		-- 检查自己场上是否存在至少1张表侧表示的「核成」怪兽
		and Duel.IsExistingMatchingCard(c55117418.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己墓地是否存在至少1张「核成兽的钢核」
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,36623431)
end
-- 效果发动时的目标确认与操作信息注册
function c55117418.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该怪兽效果的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：如果该卡可被破坏且与效果有关联，则将其破坏
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使发动无效并破坏
function c55117418.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该发动无效，且该卡与效果有关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该发动效果的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
