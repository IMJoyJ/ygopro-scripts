--沼地の魔獣王
-- 效果：
-- 这张卡可以代替融合怪兽素材的其中1只来融合。这个时候，其他的融合素材必须是指定的融合素材。
function c99426834.initial_effect(c)
	-- 这张卡可以代替融合素材中的1只来融合。这个时候，其他的融合素材必须是指定的融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_FUSION_SUBSTITUTE)
	e1:SetCondition(c99426834.subcon)
	c:RegisterEffect(e1)
end
-- 代替融合素材效果的适用条件：当此卡位于手牌、主要怪兽区或墓地时，才可以作为代替融合素材使用。
function c99426834.subcon(e)
	return e:GetHandler():IsLocation(LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
end
