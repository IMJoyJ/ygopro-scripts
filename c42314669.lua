--完全防音壁
-- 效果：
-- 自己场上没有同调怪兽表侧表示存在的场合，主要阶段1的开始时才能发动。直到下次的对方的结束阶段时，双方不能把同调怪兽特殊召唤。
function c42314669.initial_effect(c)
	-- 自己场上没有同调怪兽表侧表示存在的场合，主要阶段1的开始时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c42314669.condition)
	e1:SetOperation(c42314669.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断卡片是否为表侧表示且是同调怪兽，用于检查自己场上是否存在表侧同调怪兽。
function c42314669.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 发动条件判定：当前为主要阶段1且为本阶段开始时（尚未进行过操作），并且自己场上没有表侧表示的同调怪兽。
function c42314669.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是主要阶段1，且玩家在当前阶段尚未进行过操作（即处于主要阶段1的开始时）。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity()
		-- 检查自己的主要怪兽区域不存在满足cfilter条件的卡（即不存在表侧表示的同调怪兽）。
		and not Duel.IsExistingMatchingCard(c42314669.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果处理：创建一个持续到下次对方结束阶段的领域效果，该效果禁止双方玩家特殊召唤同调怪兽。
function c42314669.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 直到下次的对方的结束阶段时，双方不能把同调怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetTarget(c42314669.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将刚创建的禁止特殊召唤领域效果注册给当前玩家tp，使效果开始在场上适用。
	Duel.RegisterEffect(e1,tp)
end
-- 限制函数：作为禁止特殊召唤效果的对象判断条件，仅当要特殊召唤的怪兽为同调怪兽时受到禁止。
function c42314669.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsType(TYPE_SYNCHRO)
end
