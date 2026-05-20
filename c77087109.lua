--クロック・リゾネーター
-- 效果：
-- 只要这张卡在场上表侧守备表示存在，这张卡1回合只有1次不会被战斗或者卡的效果破坏。
function c77087109.initial_effect(c)
	-- 只要这张卡在场上表侧守备表示存在，这张卡1回合只有1次不会被战斗或者卡的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetValue(c77087109.valcon)
	c:RegisterEffect(e1)
end
-- 检查破坏原因是否为战斗或卡的效果，并确认自身处于守备表示，以满足一回合一次不被破坏的效果条件。
function c77087109.valcon(e,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsDefensePos()
end
