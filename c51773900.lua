--カーム・マジック
-- 效果：
-- 主要阶段一的开始时才能发动。那个回合的主要阶段时以及战斗阶段时，双方玩家不能把怪兽通常召唤·反转召唤·特殊召唤。
function c51773900.initial_effect(c)
	-- 主要阶段一的开始时才能发动。那个回合的主要阶段时以及战斗阶段时，双方玩家不能把怪兽通常召唤·反转召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c51773900.condition)
	e1:SetOperation(c51773900.operation)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数，限制只能在主要阶段1的开始时发动
function c51773900.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1，且玩家在当前阶段尚未进行任何操作（即阶段开始时）
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity()
end
-- 定义效果处理函数，注册限制双方玩家进行各种召唤的全局效果
function c51773900.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 那个回合的主要阶段时以及战斗阶段时，双方玩家不能把怪兽通常召唤·反转召唤·特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetCondition(c51773900.sumcon)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,1)
	-- 向全局环境注册限制双方玩家特殊召唤怪兽的效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 向全局环境注册限制双方玩家通常召唤怪兽的效果
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	-- 向全局环境注册限制双方玩家反转召唤怪兽的效果
	Duel.RegisterEffect(e3,tp)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CANNOT_MSET)
	-- 向全局环境注册限制双方玩家里侧表示通常召唤（覆盖）怪兽的效果
	Duel.RegisterEffect(e4,tp)
end
-- 定义限制召唤效果的生效条件函数，判断当前是否处于主要阶段或战斗阶段
function c51773900.sumcon(e)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_MAIN1 and ph<=PHASE_MAIN2
end
