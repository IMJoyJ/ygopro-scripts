--闇
-- 效果：
-- 场上表侧表示存在的恶魔族·魔法师族怪兽的攻击力·守备力上升200。场上表侧表示存在的天使族怪兽的攻击力·守备力下降200。
function c59197169.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 场上表侧表示存在的恶魔族·魔法师族怪兽的攻击力上升200。场上表侧表示存在的天使族怪兽的攻击力下降200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(c59197169.val)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
-- 获取目标怪兽的种族，若为恶魔族或魔法师族则返回200，若为天使族则返回-200，其余返回0
function c59197169.val(e,c)
	local r=c:GetRace()
	if bit.band(r,RACE_FIEND+RACE_SPELLCASTER)>0 then return 200
	elseif bit.band(r,RACE_FAIRY)>0 then return -200
	else return 0 end
end
