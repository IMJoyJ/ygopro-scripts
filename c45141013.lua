--大熱波
-- 效果：
-- ①：自己主要阶段1开始时才能发动。直到下次的自己抽卡阶段，双方不能把效果怪兽召唤·特殊召唤。
function c45141013.initial_effect(c)
	-- ①：自己主要阶段1开始时才能发动。直到下次的自己抽卡阶段，双方不能把效果怪兽召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c45141013.condition)
	e1:SetOperation(c45141013.operation)
	c:RegisterEffect(e1)
end
-- 检查是否处于主要阶段1的开始时
function c45141013.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为主要阶段1且未进行过阶段活动
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity()
end
-- 创建并注册不能特殊召唤效果，使双方在指定阶段无法特殊召唤效果怪兽
function c45141013.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 创建并注册不能召唤效果，使双方在指定阶段无法召唤效果怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetTarget(c45141013.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将效果e1注册给玩家tp
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 将效果e2注册给玩家tp
	Duel.RegisterEffect(e2,tp)
end
-- 限制召唤或特殊召唤的目标必须为效果怪兽且不是再度召唤
function c45141013.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:GetOriginalType()&TYPE_EFFECT>0 and sumtype~=SUMMON_TYPE_DUAL
end
