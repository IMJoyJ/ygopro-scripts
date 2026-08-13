--イリュージョン・シープ
-- 效果：
-- 这张卡可以作为1只融合素材怪兽的代替。那个时候，其他的融合素材怪兽必须是正规品。
function c30451366.initial_effect(c)
	-- 这张卡可以作为1只融合素材怪兽的代替。那个时候，其他的融合素材怪兽必须是正规品。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_FUSION_SUBSTITUTE)
	e1:SetCondition(c30451366.subcon)
	c:RegisterEffect(e1)
end
-- 该函数是代替融合素材效果的适用条件：判断效果持有者（这张卡）当前所在位置是否在手牌、主要怪兽区域或墓地，只有在这三个区域之一时才能作为融合素材怪兽的代替。
function c30451366.subcon(e)
	return e:GetHandler():IsLocation(LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
end
