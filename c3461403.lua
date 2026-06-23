--不死武士の悼み
-- 效果：
-- ①：自己墓地的怪兽变成战士族。
-- ②：自己·对方的结束阶段才能发动。自己场上的怪兽全部破坏。
local s,id,o=GetID()
-- 注册卡片的发动效果，使卡片可以在自由时点发动
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己墓地的怪兽变成战士族
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_GRAVE,0)
	e2:SetValue(RACE_WARRIOR)
	c:RegisterEffect(e2)
	-- 自己·对方的结束阶段才能发动。自己场上的怪兽全部破坏
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
-- 设置效果的发动目标，获取场上怪兽并准备破坏
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上所有怪兽的组
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	if chk==0 then return #g>0 end
	-- 设置连锁操作信息，确定将要破坏的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 执行效果的破坏操作，将场上所有怪兽破坏
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有怪兽的组
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	-- 将目标怪兽以效果原因破坏
	Duel.Destroy(g,REASON_EFFECT)
end
