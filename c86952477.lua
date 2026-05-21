--シャインナイト
-- 效果：
-- 只要这张卡在场上表侧守备表示存在，这张卡的等级变成4星。
function c86952477.initial_effect(c)
	-- 只要这张卡在场上表侧守备表示存在，这张卡的等级变成4星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c86952477.lvcon)
	e1:SetValue(4)
	c:RegisterEffect(e1)
end
-- 判断此卡是否处于守备表示，作为等级变更效果的生效条件
function c86952477.lvcon(e)
	return e:GetHandler():IsDefensePos()
end
