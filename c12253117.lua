--世界の平定
-- 效果：
-- 场地卡发动时才能发动。直到回合结束时场地卡的效果无效。
function c12253117.initial_effect(c)
	-- 场地卡发动时才能发动。直到回合结束时场地卡的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c12253117.condition)
	e1:SetOperation(c12253117.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的条件判断函数，用于判断是否为场地卡的发动
function c12253117.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_FIELD)
end
-- 效果发动时的处理函数，用于设置场地卡效果无效的处理
function c12253117.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 直到回合结束时场地卡的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1:SetTarget(c12253117.distarget)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1注册给玩家tp，使场地卡效果无效
	Duel.RegisterEffect(e1,tp)
end
-- 目标选择函数，用于筛选场地卡
function c12253117.distarget(e,c)
	return c:IsType(TYPE_FIELD)
end
