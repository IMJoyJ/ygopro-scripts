--武神器－チカヘシ
-- 效果：
-- ①：只要这张卡在怪兽区域守备表示存在，这张卡以外的自己场上的「武神」怪兽不会被效果破坏。
function c80555062.initial_effect(c)
	-- ①：只要这张卡在怪兽区域守备表示存在，这张卡以外的自己场上的「武神」怪兽不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c80555062.target)
	e1:SetCondition(c80555062.con)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
-- 检查自身是否在怪兽区域守备表示存在，作为效果适用的条件
function c80555062.con(e)
	return e:GetHandler():IsDefensePos()
end
-- 过滤出自身以外的自己场上的「武神」怪兽作为效果适用对象
function c80555062.target(e,c)
	return c~=e:GetHandler() and c:IsSetCard(0x88)
end
