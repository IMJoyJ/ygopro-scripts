--妖精王オベロン
-- 效果：
-- ①：只要这张卡在怪兽区域守备表示存在，自己场上的植物族怪兽的攻击力·守备力上升500。
function c45425051.initial_effect(c)
	-- ①：只要这张卡在怪兽区域守备表示存在，自己场上的植物族怪兽的攻击力·守备力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(c45425051.con)
	e1:SetTarget(c45425051.tg)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(500)
	c:RegisterEffect(e2)
end
-- 效果条件：判定效果持有者（这张卡）是否为守备表示，即只要这张卡在怪兽区域守备表示存在时，该永续效果才适用。
function c45425051.con(e)
	return e:GetHandler():IsDefensePos()
end
-- 效果适用对象筛选：仅选择自己场上的植物族怪兽，使其受到攻击力·守备力上升的效果。
function c45425051.tg(e,c)
	return c:IsRace(RACE_PLANT)
end
