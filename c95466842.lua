--水精鱗－アビスラング
-- 效果：
-- 只要这张卡在场上表侧表示存在，对方不能选择其他的水属性怪兽作为攻击对象。此外，只要这张卡在场上表侧表示存在，自己场上的水属性怪兽的攻击力上升300。
function c95466842.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，对方不能选择其他的水属性怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c95466842.atlimit)
	c:RegisterEffect(e1)
	-- 此外，只要这张卡在场上表侧表示存在，自己场上的水属性怪兽的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	-- 设置效果的影响目标为水属性怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER))
	e2:SetValue(300)
	c:RegisterEffect(e2)
end
-- 判断目标怪兽是否为自身以外的表侧表示水属性怪兽
function c95466842.atlimit(e,c)
	return c~=e:GetHandler() and c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
