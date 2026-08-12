--闇の幻影
-- 效果：
-- 场上表侧表示存在的暗属性怪兽为对象的效果怪兽的效果·魔法·陷阱卡的发动无效并破坏。
function c5562461.initial_effect(c)
	-- 场上表侧表示存在的暗属性怪兽为对象的效果怪兽的效果·魔法·陷阱卡的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c5562461.condition)
	e1:SetTarget(c5562461.target)
	e1:SetOperation(c5562461.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的暗属性怪兽
function c5562461.cfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 发动条件：检查被连锁的效果是否以场上表侧表示的暗属性怪兽为对象，且该发动可以被无效
function c5562461.condition(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	if not re:IsActiveType(TYPE_MONSTER) and not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 获取当前连锁的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 检查对象中是否存在场上表侧表示的暗属性怪兽，且该连锁的发动可以被无效
	return tg and tg:IsExists(c5562461.cfilter,1,nil) and Duel.IsChainNegatable(ev)
end
-- 设置无效发动与破坏的操作信息
function c5562461.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该连锁的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使发动无效并破坏
function c5562461.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使发动无效，且该卡仍与效果关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
