--先史遺産マッドゴーレム・シャコウキ
-- 效果：
-- 只要这张卡在场上表侧表示存在，自己场上的名字带有「先史遗产」的怪兽向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c67559101.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，自己场上的名字带有「先史遗产」的怪兽向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c67559101.target)
	c:RegisterEffect(e1)
end
-- 限定该贯穿效果仅适用于自己场上的「先史遗产」怪兽
function c67559101.target(e,c)
	return c:IsSetCard(0x70)
end
