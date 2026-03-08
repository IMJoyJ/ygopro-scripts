--完全防音壁
-- 效果：
-- 自己场上没有同调怪兽表侧表示存在的场合，主要阶段1的开始时才能发动。直到下次的对方的结束阶段时，双方不能把同调怪兽特殊召唤。
function c42314669.initial_effect(c)
	-- 效果原文内容：自己场上没有同调怪兽表侧表示存在的场合，主要阶段1的开始时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c42314669.condition)
	e1:SetOperation(c42314669.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤场上表侧表示的同调怪兽
function c42314669.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 效果作用：检查是否处于主要阶段1开始时且自己场上没有同调怪兽表侧表示
function c42314669.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查是否处于主要阶段1开始时
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity()
		-- 效果作用：检查自己场上是否存在表侧表示的同调怪兽
		and not Duel.IsExistingMatchingCard(c42314669.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果作用：创建并注册一个禁止双方同调怪兽特殊召唤的效果
function c42314669.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文内容：直到下次的对方的结束阶段时，双方不能把同调怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetTarget(c42314669.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 效果作用：将效果e1注册给玩家tp
	Duel.RegisterEffect(e1,tp)
end
-- 效果作用：设定禁止特殊召唤的条件为同调怪兽
function c42314669.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsType(TYPE_SYNCHRO)
end
