--封魔の矢
-- 效果：
-- 不能对应这张卡的发动让魔法·陷阱·怪兽的效果发动。
-- ①：自己或者对方的战斗阶段开始时才能发动。这张卡的发动后，直到回合结束时双方不能把魔法·陷阱卡的效果发动。
function c97120394.initial_effect(c)
	-- 不能对应这张卡的发动让魔法·陷阱·怪兽的效果发动。①：自己或者对方的战斗阶段开始时才能发动。这张卡的发动后，直到回合结束时双方不能把魔法·陷阱卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_START)
	e1:SetCondition(c97120394.condition)
	e1:SetTarget(c97120394.target)
	e1:SetOperation(c97120394.activate)
	c:RegisterEffect(e1)
end
-- 判定当前阶段是否为战斗阶段开始时的发动条件函数
function c97120394.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为战斗阶段开始时
	return Duel.GetCurrentPhase()==PHASE_BATTLE_START
end
-- 效果发动的目标处理函数，并在卡片发动时限制对方进行连锁
function c97120394.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设置连锁限制，使任何效果都不能对应这张卡的发动而发动
		Duel.SetChainLimit(aux.FALSE)
	end
end
-- 效果处理的执行函数，用于注册限制双方发动魔陷效果的全局效果
function c97120394.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 这张卡的发动后，直到回合结束时双方不能把魔法·陷阱卡的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetValue(c97120394.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局注册该限制发动效果
	Duel.RegisterEffect(e1,tp)
end
-- 判定被限制发动的效果是否为魔法或陷阱卡效果的过滤函数
function c97120394.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
