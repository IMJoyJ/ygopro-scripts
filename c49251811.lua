--魔法探査の石版
-- 效果：
-- 永续魔法卡发动时才能发动。直到回合结束时场上的全部永续魔法卡的效果无效。
function c49251811.initial_effect(c)
	-- 永续魔法卡发动时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c49251811.condition)
	e1:SetOperation(c49251811.activate)
	c:RegisterEffect(e1)
end
-- 判断当前连锁被连锁的效果是否为永续魔法卡的发动：必须是魔法卡的发动，且该魔法卡类型为永续魔法。
function c49251811.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetActiveType()==TYPE_CONTINUOUS+TYPE_SPELL
end
-- 处理时创建一个持续到回合结束的无效效果，覆盖双方魔陷区，使场上所有永续魔法卡的效果无效化。
function c49251811.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 直到回合结束时场上的全部永续魔法卡的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1:SetTarget(c49251811.distarget)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述无效效果注册到当前玩家tp，使其在场上持续适用，并在结束阶段自动重置。
	Duel.RegisterEffect(e1,tp)
end
-- 作为无效效果的对象筛选条件：仅当卡片类型为永续魔法卡（TYPE_CONTINUOUS+TYPE_SPELL）时才被无效。
function c49251811.distarget(e,c)
	return c:GetType()==TYPE_CONTINUOUS+TYPE_SPELL
end
