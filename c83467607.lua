--リフレクト・ネイチャー
-- 效果：
-- 这个回合，对方发动的给与基本分伤害的效果变成给与对方基本分伤害的效果。
function c83467607.initial_effect(c)
	-- 这个回合，对方发动的给与基本分伤害的效果变成给与对方基本分伤害的效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c83467607.operation)
	c:RegisterEffect(e1)
end
-- 在魔法卡发动成功时，创建一个持续到回合结束的、将自身受到的伤害反射给对方的全局效果
function c83467607.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 对方发动的给与基本分伤害的效果变成给与对方基本分伤害的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REFLECT_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c83467607.refcon)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将反射伤害的效果注册给当前玩家
	Duel.RegisterEffect(e1,tp)
end
-- 判断伤害来源是否为对方发动的非永续效果，满足条件则触发伤害反射
function c83467607.refcon(e,re,val,r,rp,rc)
	return re and not re:IsHasType(EFFECT_TYPE_CONTINUOUS) and rp==1-e:GetOwnerPlayer()
end
