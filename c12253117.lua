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
-- 发动条件判断：当前连锁中发动的效果必须为场地魔法卡的“魔陷发动”，即只有场地魔法卡发动时才能发动本卡。
function c12253117.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_FIELD)
end
-- 效果处理：以本卡为来源创建持续到回合结束的无效化效果，作用于双方魔法与陷阱区域（含场地区域），使所有符合条件的场地魔法卡效果无效化，并注册该效果。
function c12253117.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 直到回合结束时场地卡的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1:SetTarget(c12253117.distarget)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将已经生成的“场地卡效果无效化”持续效果注册到当前玩家，使其从此刻开始适用。
	Duel.RegisterEffect(e1,tp)
end
-- 无效对象筛选：只选择场上的场地魔法卡（类型为场地）作为无效化对象。
function c12253117.distarget(e,c)
	return c:IsType(TYPE_FIELD)
end
