--聖なるあかり
-- 效果：
-- 这张卡不会被和暗属性怪兽的战斗破坏，那次战斗发生的对自己的战斗伤害变成0。只要这张卡在场上表侧表示存在，暗属性怪兽不能攻击宣言，双方不能把暗属性怪兽召唤·特殊召唤。
function c2980764.initial_effect(c)
	-- 这张卡不会被和暗属性怪兽的战斗破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetValue(c2980764.tglimit)
	c:RegisterEffect(e1)
	-- 那次战斗发生的对自己的战斗伤害变成0
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(c2980764.tglimit)
	c:RegisterEffect(e2)
	-- 暗属性怪兽不能攻击宣言
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c2980764.tglimit)
	c:RegisterEffect(e3)
	-- 双方不能把暗属性怪兽召唤·特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_SUMMON)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,1)
	e4:SetTarget(c2980764.sumlimit)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	c:RegisterEffect(e5)
end
-- 效果作用：判断目标是否为暗属性怪兽
function c2980764.tglimit(e,c)
	return c and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 效果作用：判断目标是否为暗属性怪兽
function c2980764.sumlimit(e,c)
	return c:IsAttribute(ATTRIBUTE_DARK)
end
