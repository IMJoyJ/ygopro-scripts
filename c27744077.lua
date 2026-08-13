--絶体絶命
-- 效果：
-- 只能在对方回合发动。这个回合对方怪兽的攻击，全部变成对玩家的直接攻击。
function c27744077.initial_effect(c)
	-- 只能在对方回合发动。这个回合对方怪兽的攻击，全部变成对玩家的直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START)
	e1:SetCondition(c27744077.condition)
	e1:SetOperation(c27744077.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件：只有当前回合玩家不是自己（即对方回合）且当前阶段为主要阶段2之前的阶段时，该卡才能发动。
function c27744077.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断条件：当前回合玩家不是自己，且当前阶段早于主要阶段2，满足这两点才可发动。
	return Duel.GetTurnPlayer()~=tp and Duel.GetCurrentPhase()<PHASE_MAIN2
end
-- 效果处理：创建一个全场持续效果，使己方场上（含里侧）的怪兽成为不能攻击的对象，从而迫使对方怪兽只能直接攻击玩家；该效果持续到回合结束。
function c27744077.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合对方怪兽的攻击，全部变成对玩家的直接攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetValue(c27744077.imval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1注册到当前玩家tp，使其作为全场效果开始适用。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetProperty(0)
	e2:SetValue(0)
	-- 将克隆效果e2也注册到当前玩家tp，作为免疫判定用的基准效果（本身不直接生效）。
	Duel.RegisterEffect(e2,tp)
	e1:SetLabelObject(e2)
end
-- 效果值函数：若受效果影响的怪兽并不免疫作为基准的e2效果，则返回true，即该怪兽不能成为攻击对象；若怪兽免疫e2，则返回false，该怪兽仍可被攻击。
function c27744077.imval(e,c)
	return not c:IsImmuneToEffect(e:GetLabelObject())
end
