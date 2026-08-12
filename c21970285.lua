--竜角の狩猟者
-- 效果：
-- ←3 【灵摆】 3→
-- ①：场上的通常怪兽的攻击力上升200，自己的通常怪兽的战斗发生的对自己的战斗伤害变成0。
-- 【怪兽描述】
-- 为了拯救瘟疫中受苦的故乡村庄，因灵药原料是龙之角而滥捕的女战士。那个村庄已经遭到被赶离巢穴的龙们践踏并烧毁一事，她还并不知情…
function c21970285.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性，使其可以灵摆召唤和发动灵摆卡
	aux.EnablePendulumAttribute(c)
	-- ①：场上的通常怪兽的攻击力上升200
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c21970285.efilter)
	e2:SetValue(200)
	c:RegisterEffect(e2)
	-- ①：自己的通常怪兽的战斗发生的对自己的战斗伤害变成0
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_PZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c21970285.efilter)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 效果适用对象为通常怪兽
function c21970285.efilter(e,c)
	return c:IsType(TYPE_NORMAL)
end
