--カーム・マジック
-- 效果：
-- 主要阶段一的开始时才能发动。那个回合的主要阶段时以及战斗阶段时，双方玩家不能把怪兽通常召唤·反转召唤·特殊召唤。
function c51773900.initial_effect(c)
	-- 主要阶段一的开始时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c51773900.condition)
	e1:SetOperation(c51773900.operation)
	c:RegisterEffect(e1)
end
-- 效果作用
function c51773900.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否处于主要阶段一的开始时
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity()
end
-- 效果作用
function c51773900.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 那个回合的主要阶段时以及战斗阶段时，双方玩家不能把怪兽通常召唤·反转召唤·特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetCondition(c51773900.sumcon)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,1)
	-- 将不能特殊召唤的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 将不能通常召唤的效果注册给玩家
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	-- 将不能反转召唤的效果注册给玩家
	Duel.RegisterEffect(e3,tp)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CANNOT_MSET)
	-- 将不能覆盖怪兽的效果注册给玩家
	Duel.RegisterEffect(e4,tp)
end
-- 效果作用
function c51773900.sumcon(e)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_MAIN1 and ph<=PHASE_MAIN2
end
