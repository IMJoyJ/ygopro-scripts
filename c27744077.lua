--絶体絶命
-- 效果：
-- 只能在对方回合发动。这个回合对方怪兽的攻击，全部变成对玩家的直接攻击。
function c27744077.initial_effect(c)
	-- 效果原文内容：只能在对方回合发动。这个回合对方怪兽的攻击，全部变成对玩家的直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START)
	e1:SetCondition(c27744077.condition)
	e1:SetOperation(c27744077.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：判断是否在对方回合且未进入主要阶段2
function c27744077.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：当前回合玩家不是发动者，且当前阶段小于主要阶段2
	return Duel.GetTurnPlayer()~=tp and Duel.GetCurrentPhase()<PHASE_MAIN2
end
-- 效果作用：创建并注册一个影响对方怪兽攻击目标的效果
function c27744077.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文内容：只能在对方回合发动。这个回合对方怪兽的攻击，全部变成对玩家的直接攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetValue(c27744077.imval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 效果作用：将效果e1注册给玩家tp
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetProperty(0)
	e2:SetValue(0)
	-- 效果作用：将效果e2注册给玩家tp
	Duel.RegisterEffect(e2,tp)
	e1:SetLabelObject(e2)
end
-- 效果作用：判断目标怪兽是否免疫效果
function c27744077.imval(e,c)
	return not c:IsImmuneToEffect(e:GetLabelObject())
end
