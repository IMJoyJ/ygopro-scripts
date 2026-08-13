--ジャイロイド
-- 效果：
-- 这张卡1回合1次不会被战斗破坏。（伤害计算适用）。
function c18325492.initial_effect(c)
	-- 这张卡1回合1次不会被战斗破坏。（伤害计算适用）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetValue(c18325492.valcon)
	c:RegisterEffect(e1)
end
-- 该函数作为效果的值判断条件：检查造成破坏的原因是否包含战斗破坏（REASON_BATTLE），若是则满足‘不会被战斗破坏’的适用条件，即仅在战斗破坏时生效。
function c18325492.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
