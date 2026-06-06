--魔力終了宣告
-- 效果：
-- 对方发动永续魔法卡时才能发动。那张卡的发动和效果无效，并且破坏。
function c10069180.initial_effect(c)
	-- 对方发动永续魔法卡时才能发动。那张卡的发动和效果无效，并且破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c10069180.condition)
	e1:SetTarget(c10069180.target)
	e1:SetOperation(c10069180.activate)
	c:RegisterEffect(e1)
end
-- 发动条件的判断
function c10069180.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方发动永续魔法卡，且该连锁的发动可以被无效的场合
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetActiveType()==TYPE_SPELL+TYPE_CONTINUOUS and Duel.IsChainNegatable(ev)
end
-- 效果发动时的处理
function c10069180.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置无效发动的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏该卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理的实现
function c10069180.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的发动无效，且该卡与此效果有联系的场合
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
