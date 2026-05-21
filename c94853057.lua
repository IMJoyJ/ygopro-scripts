--閃光の追放者
-- 效果：
-- 只要这张卡在场上表侧表示存在，被送去墓地的卡不去墓地从游戏中除外。
function c94853057.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，被送去墓地的卡不去墓地从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_DECK,LOCATION_DECK)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)
end
