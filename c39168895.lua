--怒れる類人猿
-- 效果：
-- 当这张卡在场上以表侧守备表示存在时，这张卡被破坏。当这张卡处于可以进行攻击的状态时，这张卡的控制者必须让这张卡进行攻击。
function c39168895.initial_effect(c)
	-- 当这张卡处于可以进行攻击的状态时，这张卡的控制者必须让这张卡进行攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MUST_ATTACK)
	c:RegisterEffect(e1)
	-- 当这张卡在场上以表侧守备表示存在时，这张卡被破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_SELF_DESTROY)
	e3:SetCondition(c39168895.descon)
	c:RegisterEffect(e3)
end
-- 判断效果对象（这张卡）是否处于守备表示，用于决定自我破坏效果是否适用。
function c39168895.descon(e)
	return e:GetHandler():IsDefensePos()
end
