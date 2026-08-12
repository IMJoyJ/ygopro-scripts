--次元要塞兵器
-- 效果：
-- 只要这张卡在场上表侧表示存在，双方不能从卡组把卡送去墓地。
function c1596508.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，双方不能从卡组把卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TO_GRAVE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_DECK,LOCATION_DECK)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上表侧表示存在，双方不能从卡组把卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_DISCARD_DECK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,1)
	c:RegisterEffect(e2)
end
