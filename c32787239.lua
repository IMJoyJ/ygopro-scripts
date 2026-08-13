--EMラ・パンダ
-- 效果：
-- ←3 【灵摆】 3→
-- ①：1回合1次，自己主要阶段才能发动。这张卡的灵摆刻度上升1（最多到12）。
-- 【怪兽效果】
-- 「娱乐伙伴 喇叭熊猫」的怪兽效果1回合只能使用1次。
-- ①：自己的灵摆怪兽被选择作为攻击对象时才能发动。那次攻击无效。
function c32787239.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性，使其可以作为灵摆卡发动并进行灵摆召唤。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，自己主要阶段才能发动。这张卡的灵摆刻度上升1（最多到12）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32787239,0))  --"灵摆刻度上升"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c32787239.sctg)
	e2:SetOperation(c32787239.scop)
	c:RegisterEffect(e2)
	-- 「娱乐伙伴 喇叭熊猫」的怪兽效果1回合只能使用1次。①：自己的灵摆怪兽被选择作为攻击对象时才能发动。那次攻击无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(32787239,1))  --"攻击无效"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,32787239)
	e3:SetCondition(c32787239.condition)
	e3:SetOperation(c32787239.operation)
	c:RegisterEffect(e3)
end
-- 灵摆刻度上升效果的发动条件：这张卡的左灵摆刻度小于12时才能发动。
function c32787239.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetLeftScale()<12 end
end
-- 效果处理：若这张卡仍与效果相关且左灵摆刻度未满12，则令其左、右灵摆刻度各上升1。
function c32787239.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:GetLeftScale()>=12 then return end
	-- 这张卡的灵摆刻度上升1（最多到12）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LSCALE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_RSCALE)
	c:RegisterEffect(e2)
end
-- 攻击无效效果的发动条件：攻击对象是自己场上表侧表示的灵摆怪兽。
function c32787239.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前被攻击的怪兽。
	local d=Duel.GetAttackTarget()
	return d and d:IsControler(tp) and d:IsFaceup() and d:IsType(TYPE_PENDULUM)
end
-- 攻击无效效果的处理：无效此次攻击。
function c32787239.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 无效此次攻击（若攻击已被其他效果无效或导致攻击的卡不能攻击则返回失败）。
	Duel.NegateAttack()
end
