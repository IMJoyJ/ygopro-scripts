--ヒーローズルール2
-- 效果：
-- 墓地的卡为对象的效果怪兽的效果·魔法·陷阱卡的发动无效并破坏。
function c85854214.initial_effect(c)
	-- 墓地的卡为对象的效果怪兽的效果·魔法·陷阱卡的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c85854214.condition)
	e1:SetTarget(c85854214.target)
	e1:SetOperation(c85854214.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件：必须是取对象的效果，且对象中包含墓地的卡，该发动可以被无效，且是怪兽效果或魔陷的发动
function c85854214.condition(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
		-- 并且该连锁的发动可以被无效，且发动效果的卡是怪兽卡或者是魔法·陷阱卡的发动
		and Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 设置效果发动的目标：确定无效发动与破坏的操作信息
function c85854214.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：如果该卡可被破坏且与效果有联系，则将其破坏
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使该发动无效并破坏
function c85854214.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该发动无效，且该卡在场上或与效果仍有联系
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该发动效果的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
