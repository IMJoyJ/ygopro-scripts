--深海王デビルシャーク
-- 效果：
-- 这张卡1回合只有1次不会被不指定对象的卡的效果破坏。
function c44223284.initial_effect(c)
	-- 这张卡1回合只有1次不会被不指定对象的卡的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetValue(c44223284.valcon)
	c:RegisterEffect(e1)
end
-- 该函数作为EFFECT_INDESTRUCTABLE_COUNT效果的判定条件：当破坏原因为效果破坏且该效果不具有EFFECT_FLAG_CARD_TARGET（即不取对象）时返回真，使这张卡本回合仅此一次不会被不指定对象的卡的效果破坏。
function c44223284.valcon(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
end
