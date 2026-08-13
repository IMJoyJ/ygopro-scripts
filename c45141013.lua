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
-- 发动条件函数：检查当前是否处于自己主要阶段1，且本阶段尚未进行过任何操作，满足“自己主要阶段1开始时”的发动时点。
function c45141013.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回判定结果：当前阶段为主要阶段1 且 本阶段尚无任何操作记录（即处于主要阶段1刚开始的时机）。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity()
end
-- 效果处理整体操作：创建两个永续型规则效果，分别禁止双方特殊召唤和通常召唤效果怪兽，持续到下次自己的抽卡阶段（通过RESET_PHASE+PHASE_END与计数值2实现）。
function c45141013.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 直到下次的自己抽卡阶段，双方不能把效果怪兽召唤·特殊召唤。（其中sumlimit用于限制“效果怪兽”的范围：卡片的原始类型包含效果怪兽，且召唤方式不是二重召唤）
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetTarget(c45141013.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将禁止特殊召唤的效果e1作为以双方玩家为对象的场地效果注册到tp方，使其开始适用。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 将禁止召唤的效果e2（由e1克隆后仅修改效果代码为EFFECT_CANNOT_SUMMON）同样注册到tp方，使其开始适用。
	Duel.RegisterEffect(e2,tp)
end
-- 过滤函数sumlimit：判定怪兽是否为效果怪兽（原始类型含有TYPE_EFFECT），并且当前召唤行为不是“二重召唤”（SUMMON_TYPE_DUAL），即除二重召唤外的召唤·特殊召唤都会受到限制。
function c45141013.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:GetOriginalType()&TYPE_EFFECT>0 and sumtype~=SUMMON_TYPE_DUAL
end
