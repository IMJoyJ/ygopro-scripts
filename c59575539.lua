--クレボンス
-- 效果：
-- 这张卡被选择作为攻击对象时，支付800基本分才能发动。那次攻击无效。
function c59575539.initial_effect(c)
	-- 这张卡被选择作为攻击对象时，支付800基本分才能发动。那次攻击无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59575539,0))  --"怪兽的攻击无效"
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCost(c59575539.cost)
	e1:SetOperation(c59575539.operation)
	c:RegisterEffect(e1)
end
-- 定义发动消耗（Cost）函数，用于检查并支付800基本分
function c59575539.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，检查当前玩家是否能支付800基本分
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 让当前玩家支付800基本分
	Duel.PayLPCost(tp,800)
end
-- 定义效果处理（Operation）函数，用于使攻击无效
function c59575539.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使那次攻击无效
	Duel.NegateAttack()
end
