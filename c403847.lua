--連合軍
-- 效果：
-- 自己场上的战士族怪兽的攻击力上升自己场上的战士族·魔法师族怪兽数量×200的数值。
function c403847.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上的战士族怪兽的攻击力上升自己场上的战士族·魔法师族怪兽数量×200的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果目标为场上的战士族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_WARRIOR))
	e2:SetValue(c403847.val)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断怪兽是否为表侧表示且属于战士族或魔法师族
function c403847.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR+RACE_SPELLCASTER)
end
-- 计算满足条件的怪兽数量并乘以200作为攻击力提升值
function c403847.val(e,c)
	-- 检索满足条件的怪兽数量并乘以200
	return Duel.GetMatchingGroupCount(c403847.filter,c:GetControler(),LOCATION_MZONE,0,nil)*200
end
