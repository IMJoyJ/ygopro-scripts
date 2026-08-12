--墓場からの呼び声
-- 效果：
-- 对方把「死者苏生」发动时才能发动。那张「死者苏生」的效果无效。
function c16970158.initial_effect(c)
	-- 效果注册：将此卡注册为一张可发动的魔法卡，当对方发动魔法卡时触发
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c16970158.condition)
	e1:SetTarget(c16970158.target)
	e1:SetOperation(c16970158.activate)
	c:RegisterEffect(e1)
end
-- 条件判断：对方发动魔法卡时触发
function c16970158.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方发动魔法卡时触发，且该魔法卡为「死者苏生」，且该连锁可被无效
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(83764718) and Duel.IsChainDisablable(ev)
end
-- 目标设定：设置该效果的处理目标为对方发动的魔法卡
function c16970158.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将对方发动的魔法卡设为无效效果的目标
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果处理：使对方发动的魔法卡效果无效
function c16970158.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁效果无效
	Duel.NegateEffect(ev)
end
