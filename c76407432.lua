--バスター・カウンター
-- 效果：
-- ①：自己场上有「/爆裂体」怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
function c76407432.initial_effect(c)
	-- ①：自己场上有「/爆裂体」怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c76407432.condition)
	e1:SetTarget(c76407432.target)
	e1:SetOperation(c76407432.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的「/爆裂体」怪兽
function c76407432.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x104f)
end
-- 发动条件：自己场上有「/爆裂体」怪兽存在，且该连锁的发动可以被无效，且该发动为怪兽效果、魔法或陷阱卡的发动
function c76407432.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「/爆裂体」怪兽
	if not Duel.IsExistingMatchingCard(c76407432.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	-- 检查当前连锁的发动是否可以被无效
	if not Duel.IsChainNegatable(ev) then return false end
	return re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 设置无效与破坏的操作信息
function c76407432.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若该卡可被破坏且与效果有关联，则设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使发动无效并破坏
function c76407432.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使发动无效，且该卡与效果存在关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
