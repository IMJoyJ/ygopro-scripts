--魔力終了宣告
-- 效果：
-- 对方发动永续魔法卡时才能发动。那张卡的发动和效果无效，并且破坏。
function c10069180.initial_effect(c)
	-- 效果原文内容：对方发动永续魔法卡时才能发动。那张卡的发动和效果无效，并且破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c10069180.condition)
	e1:SetTarget(c10069180.target)
	e1:SetOperation(c10069180.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查是否满足发动条件
function c10069180.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：确认是对方发动的永续魔法卡且该连锁可以被无效
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetActiveType()==TYPE_SPELL+TYPE_CONTINUOUS and Duel.IsChainNegatable(ev)
end
-- 效果作用：设置发动时的处理目标
function c10069180.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：设置使对方发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 效果作用：设置破坏对方卡片的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果作用：执行发动后的处理流程
function c10069180.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：使对方发动无效并判断是否可以破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 效果作用：将对方的卡片破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
