--マジオシャレオン
-- 效果：
-- 只要对方场上有魔法·陷阱卡存在，对方不能选择这张卡作为攻击对象。此外，这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c67211766.initial_effect(c)
	-- 只要对方场上有魔法·陷阱卡存在，对方不能选择这张卡作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(c67211766.ccon)
	-- 设置不能作为攻击对象效果的适用对象过滤函数（自身不免疫该效果时适用）
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- 此外，这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
end
-- 定义不能作为攻击对象效果的生效条件函数
function c67211766.ccon(e)
	-- 判断对方场上是否存在至少1张魔法或陷阱卡
	return Duel.IsExistingMatchingCard(Card.IsType,e:GetHandlerPlayer(),0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP)
end
