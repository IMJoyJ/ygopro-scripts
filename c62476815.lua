--ゴゴゴゴーレム
-- 效果：
-- ①：守备表示的这张卡1回合只有1次不会被战斗破坏。
function c62476815.initial_effect(c)
	-- ①：守备表示的这张卡1回合只有1次不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetValue(c62476815.valcon)
	c:RegisterEffect(e1)
end
-- 判断破坏原因为战斗破坏，且自身处于守备表示
function c62476815.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0 and e:GetHandler():IsDefensePos()
end
