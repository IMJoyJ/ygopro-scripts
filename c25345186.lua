--ジェノサイド・ウォー
-- 效果：
-- 只能在主要阶段一发动。这个回合经过了战斗伤害计算的自己·对方怪兽在结束步骤时全部破坏。
function c25345186.initial_effect(c)
	-- 效果原文内容：只能在主要阶段一发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c25345186.condition)
	e1:SetOperation(c25345186.activate)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断是否处于主要阶段一
function c25345186.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：当前阶段等于主要阶段一
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 规则层面作用：设置发动时的处理流程
function c25345186.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文内容：这个回合经过了战斗伤害计算的自己·对方怪兽在结束步骤时全部破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLED)
	e1:SetOperation(c25345186.regop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 规则层面作用：将效果e1注册给玩家tp
	Duel.RegisterEffect(e1,tp)
	-- 规则层面作用：注册战斗结束时的处理效果
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetCountLimit(1)
	e2:SetOperation(c25345186.desop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 规则层面作用：将效果e2注册给玩家tp
	Duel.RegisterEffect(e2,tp)
end
-- 规则层面作用：记录参与战斗的怪兽
function c25345186.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取攻击怪兽
	local tc=Duel.GetAttacker()
	tc:RegisterFlagEffect(25345186,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	-- 规则层面作用：获取防守怪兽
	tc=Duel.GetAttackTarget()
	if tc then
		tc:RegisterFlagEffect(25345186,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 规则层面作用：过滤拥有标记效果的怪兽
function c25345186.filter(c)
	return c:GetFlagEffect(25345186)~=0
end
-- 规则层面作用：检索满足条件的怪兽组并破坏
function c25345186.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：检索满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c25345186.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 规则层面作用：以效果原因破坏怪兽组
	Duel.Destroy(g,REASON_EFFECT)
end
