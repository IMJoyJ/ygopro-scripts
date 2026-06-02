--ブルーアイズ・カオス・MAX・ドラゴン
-- 效果：
-- 「混沌形态」降临
-- 这张卡不用仪式召唤不能特殊召唤。
-- ①：只要这张卡在怪兽区域存在，这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
-- ②：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的2倍数值的战斗伤害。
function c55410871.initial_effect(c)
	aux.AddCodeList(c,21082832)
	c:EnableReviveLimit()
	-- 这张卡不用仪式召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制为仅能通过仪式召唤进行特殊召唤
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	-- 对方不能把这张卡作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置不能成为对方卡片效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 这张卡不会被对方的效果破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	-- 设置不会被对方卡片的效果破坏
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	-- ②：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的2倍数值的战斗伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_PIERCE)
	e4:SetValue(DOUBLE_DAMAGE)
	c:RegisterEffect(e4)
end
