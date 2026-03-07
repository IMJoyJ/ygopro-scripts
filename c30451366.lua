--イリュージョン・シープ
-- 效果：
-- 这张卡可以作为1只融合素材怪兽的代替。那个时候，其他的融合素材怪兽必须是正规品。
function c30451366.initial_effect(c)
	-- 这张卡可以作为1只融合素材怪兽的代替
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_FUSION_SUBSTITUTE)
	e1:SetCondition(c30451366.subcon)
	c:RegisterEffect(e1)
end
-- 效果作用：检查此卡是否在手牌、怪兽区或墓地
function c30451366.subcon(e)
	return e:GetHandler():IsLocation(LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
end
