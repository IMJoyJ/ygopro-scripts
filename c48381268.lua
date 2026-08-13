--D・ボードン
-- 效果：
-- ①：这张卡得到表示形式的以下效果。
-- ●攻击表示：只要这张卡在怪兽区域存在，自己的「变形斗士」怪兽可以直接攻击。
-- ●守备表示：只要这张卡在怪兽区域存在，这张卡以外的自己的「变形斗士」怪兽不会被战斗破坏。
function c48381268.initial_effect(c)
	-- ①：这张卡得到表示形式的以下效果。●攻击表示：只要这张卡在怪兽区域存在，自己的「变形斗士」怪兽可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(c48381268.cona)
	-- 设置效果适用对象：筛选出我方怪兽区域中满足条件（卡名含有「变形斗士」字段）的怪兽，使其获得可直接攻击的能力。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x26))
	c:RegisterEffect(e1)
	-- ●守备表示：只要这张卡在怪兽区域存在，这张卡以外的自己的「变形斗士」怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(c48381268.cond)
	e2:SetTarget(c48381268.tgd)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 效果条件判定：当效果持有者（这张卡）处于攻击表示时，直接攻击效果生效。
function c48381268.cona(e)
	return e:GetHandler():IsAttackPos()
end
-- 效果条件判定：当效果持有者（这张卡）处于守备表示时，战斗破坏抗性效果生效。
function c48381268.cond(e)
	return e:GetHandler():IsDefensePos()
end
-- 目标筛选判定：只有满足“卡名含有「变形斗士」字段”且不是效果持有者自身的怪兽，才能适用不会被战斗破坏的效果。
function c48381268.tgd(e,c)
	return c:IsSetCard(0x26) and c~=e:GetHandler()
end
