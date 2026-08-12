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
-- 判断是否满足攻击条件：场上怪兽数量大于1或手卡数量大于0时不能攻击
function c32240937.atkcon(e)
	local tp=e:GetHandlerPlayer()
	-- 如果场上怪兽数量大于1或手卡数量大于0则返回true，表示不能攻击
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)>1 or Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
end
-- 战斗结束后处理被破坏怪兽的效果无效化
function c32240937.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc:IsType(TYPE_EFFECT) and bc:IsStatus(STATUS_BATTLE_DESTROYED) then
		-- 使被破坏的效果怪兽的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x17a0000)
		bc:RegisterEffect(e1)
		-- 使被破坏的效果怪兽的卡效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+0x17a0000)
		bc:RegisterEffect(e2)
	end
end
