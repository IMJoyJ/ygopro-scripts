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
-- 过滤函数：判断怪兽是否为表侧表示、含有「魔救」字段且为同调怪兽，用于检查自己场上是否存在符合条件的「魔救」同调怪兽。
function c45730592.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x140) and c:IsType(TYPE_SYNCHRO)
end
-- 发动条件判定：自己场上有表侧表示的「魔救」同调怪兽，且当前连锁可以被无效，并且发动效果的是怪兽效果时，才满足发动条件。
function c45730592.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张满足条件的表侧表示「魔救」同调怪兽；若不存在则不满足发动条件。
	if not Duel.IsExistingMatchingCard(c45730592.filter,tp,LOCATION_MZONE,0,1,nil) then return false end
	-- 检查当前连锁的发动是否可以被无效；若该发动不能被无效，则不满足发动条件。
	if not Duel.IsChainNegatable(ev) then return false end
	return re:IsActiveType(TYPE_MONSTER)
end
-- 效果发动时的目标/操作信息设置：允许发动，将无效对象设为发动效果的怪兽，并视情况追加破坏对象信息。
function c45730592.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将本次处理确定为无效该连锁的发动，对象为连锁中的那张怪兽卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 当发动效果的怪兽可被破坏且仍与效果关联时，追加设置操作信息：将该怪兽作为破坏对象，数量为1。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使该怪兽效果的发动无效，若成功且该怪兽仍与效果关联，则将其破坏。
function c45730592.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 执行使连锁发动无效的操作，同时确认发动效果的怪兽仍与效果关联；两者成立后才继续执行破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因破坏连锁中发动效果的那只怪兽，即“那个发动无效并破坏”中的破坏处理。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
