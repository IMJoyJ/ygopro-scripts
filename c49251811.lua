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
-- 效果发动时的条件判断，确保是永续魔法卡的发动
function c49251811.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetActiveType()==TYPE_CONTINUOUS+TYPE_SPELL
end
-- 将目标永续魔法卡的效果无效化
function c49251811.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 直到回合结束时场上的全部永续魔法卡的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1:SetTarget(c49251811.distarget)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1注册给全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 目标为场上的永续魔法卡
function c49251811.distarget(e,c)
	return c:GetType()==TYPE_CONTINUOUS+TYPE_SPELL
end
