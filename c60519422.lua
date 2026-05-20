--騎士道精神
-- 效果：
-- 自己场上的怪兽和攻击力相同的怪兽战斗时不会被破坏。
function c60519422.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上的怪兽和攻击力相同的怪兽战斗时不会被破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c60519422.indtg)
	e2:SetValue(c60519422.indval)
	c:RegisterEffect(e2)
end
-- 确定受保护的我方怪兽，并将该怪兽的攻击力记录在效果的Label中
function c60519422.indtg(e,c)
	e:SetLabel(c:GetAttack())
	return true
end
-- 判断与我方怪兽进行战斗的对方怪兽的攻击力是否与记录的攻击力相同
function c60519422.indval(e,c)
	return c:IsAttack(e:GetLabel())
end
