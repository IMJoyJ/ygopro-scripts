--不死武士の悼み
-- 效果：
-- ①：自己墓地的怪兽变成战士族。
-- ②：自己·对方的结束阶段才能发动。自己场上的怪兽全部破坏。
local s,id,o=GetID()
-- 初始化并注册本卡的三个效果：e1为魔法卡发动所需的空效果，e2持续使我方墓地怪兽变为战士族，e3在自己·对方结束阶段可选发动并破坏我方场上全部怪兽。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己墓地的怪兽变成战士族。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_GRAVE,0)
	e2:SetValue(RACE_WARRIOR)
	c:RegisterEffect(e2)
	-- ②：自己·对方的结束阶段才能发动。自己场上的怪兽全部破坏。
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
-- 发动条件与操作信息设定：我方场上存在怪兽时才可发动，并预设置破坏我方场上全部怪兽的处理信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得我方场上全部怪兽，作为发动条件判断及后续破坏对象。
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	if chk==0 then return #g>0 end
	-- 设置操作信息，声明本效果将破坏上述我方场上全部怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 效果处理时再次取得我方场上全部怪兽，并以效果原因将它们全部破坏。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新取得我方场上全部怪兽，确保以当前场面为准进行破坏。
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	-- 以效果为破坏原因，将这些怪兽全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
