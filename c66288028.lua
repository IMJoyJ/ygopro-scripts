--マッシブ・ウォリアー
-- 效果：
-- 这张卡的战斗发生的对自己的战斗伤害变成0。这张卡1回合只有1次不会被战斗破坏。
function c66288028.initial_effect(c)
	-- 这张卡1回合只有1次不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetValue(c66288028.valcon)
	c:RegisterEffect(e1)
	-- 这张卡的战斗发生的对自己的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 判断破坏原因是否为战斗，使一次性不被破坏的效果仅对战斗破坏生效
function c66288028.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
