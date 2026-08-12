--A・O・J サンダー・アーマー
-- 效果：
-- 这张卡不能特殊召唤。只要这张卡在自己场上表侧表示存在，自己场上存在的名字带有「正义盟军」的怪兽攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c71438011.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 只要这张卡在自己场上表侧表示存在，自己场上存在的名字带有「正义盟军」的怪兽攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果影响的目标为名字带有「正义盟军」的怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1))
	c:RegisterEffect(e2)
end
