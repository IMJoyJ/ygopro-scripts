--絶対服従魔人
-- 效果：
-- 当自己场上只有这张卡存在且自己手卡数为零时这张卡才能进行攻击。被这张卡破坏的效果怪兽的效果无效化。
function c32240937.initial_effect(c)
	-- 当自己场上只有这张卡存在且自己手卡数为零时这张卡才能进行攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetCondition(c32240937.atkcon)
	c:RegisterEffect(e1)
	-- 被这张卡破坏的效果怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLED)
	e2:SetOperation(c32240937.negop)
	c:RegisterEffect(e2)
end
-- 攻击限制的判定条件：当自己场上除这张卡外还有其他卡或手牌数大于0时，返回 true，使 EFFECT_CANNOT_ATTACK 生效，即不能攻击。
function c32240937.atkcon(e)
	local tp=e:GetHandlerPlayer()
	-- 统计自己场上的卡数和手牌数：若场上卡数 >1 或手牌数 >0，则说明不满足“自己场上只有这张卡且手牌数为零”，因此禁止攻击。
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)>1 or Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
end
-- 伤害计算后，若这张卡的战斗对象是效果怪兽且该怪兽已被战斗破坏确定，则给该怪兽赋予效果无效化：先通过 EFFECT_DISABLE 使其怪兽效果无效，再通过 EFFECT_DISABLE_EFFECT 使其效果无效化状态持续（离场后仍无效），并设定在相关事件后重置。
function c32240937.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc:IsType(TYPE_EFFECT) and bc:IsStatus(STATUS_BATTLE_DESTROYED) then
		-- 被这张卡破坏的效果怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x17a0000)
		bc:RegisterEffect(e1)
		-- 被这张卡破坏的效果怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+0x17a0000)
		bc:RegisterEffect(e2)
	end
end
