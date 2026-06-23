--G・B・ハンター
-- 效果：
-- 只要这张卡在场上表侧表示存在，场上存在的卡不能回到卡组。
function c4130270.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，场上存在的卡不能回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TO_DECK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	-- 设置效果目标为场上存在的卡
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_ONFIELD))
	c:RegisterEffect(e1)
end
