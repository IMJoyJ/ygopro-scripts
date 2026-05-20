--古代の機械巨人
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
-- ②：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c83104731.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ②：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	-- ①：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(c83104731.aclimit)
	e3:SetCondition(c83104731.actcon)
	c:RegisterEffect(e3)
end
-- 判断被限制发动的效果是否为魔法·陷阱卡的发动
function c83104731.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 判断此卡是否为当前攻击怪兽的条件函数
function c83104731.actcon(e)
	-- 判断当前攻击的怪兽是否是此卡自身
	return Duel.GetAttacker()==e:GetHandler()
end
