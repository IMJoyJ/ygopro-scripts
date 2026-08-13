--ジェノサイド・ウォー
-- 效果：
-- 只能在主要阶段一发动。这个回合经过了战斗伤害计算的自己·对方怪兽在结束步骤时全部破坏。
function c25345186.initial_effect(c)
	-- 只能在主要阶段一发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c25345186.condition)
	e1:SetOperation(c25345186.activate)
	c:RegisterEffect(e1)
end
-- 此效果只能在主要阶段一发动，若当前阶段不是主要阶段一则无法发动。
function c25345186.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段一。
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 发动后，在场上注册两个持续效果：第一个在伤害计算后给参与战斗的怪兽打上标记，第二个在战斗阶段结束时破坏带标记的怪兽。
function c25345186.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合经过了战斗伤害计算的自己·对方怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLED)
	e1:SetOperation(c25345186.regop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将第一个持续效果注册到场上，由当前玩家控制，用于监听伤害计算后的战斗事件。
	Duel.RegisterEffect(e1,tp)
	-- 这个回合经过了战斗伤害计算的自己·对方怪兽在结束步骤时全部破坏。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetCountLimit(1)
	e2:SetOperation(c25345186.desop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将第二个持续效果注册到场上，用于在战斗阶段结束时执行破坏处理。
	Duel.RegisterEffect(e2,tp)
end
-- 当发生伤害计算后，获取攻击怪兽和攻击对象怪兽，并为它们各打上一个标记（表示本次战斗经过了伤害计算）。
function c25345186.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行战斗的攻击怪兽。
	local tc=Duel.GetAttacker()
	tc:RegisterFlagEffect(25345186,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	-- 获取被攻击的怪兽（若存在），用于同样打上标记。
	tc=Duel.GetAttackTarget()
	if tc then
		tc:RegisterFlagEffect(25345186,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 过滤函数：判断怪兽是否带有灭绝战争赋予的标记（即本回合是否经过了战斗伤害计算）。
function c25345186.filter(c)
	return c:GetFlagEffect(25345186)~=0
end
-- 在战斗阶段结束时，收集所有带有标记的怪兽并全部破坏。
function c25345186.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方主要怪兽区中所有带有标记的怪兽。
	local g=Duel.GetMatchingGroup(c25345186.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将这些怪兽以效果原因全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
