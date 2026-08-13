--破壊神 ヴァサーゴ
-- 效果：
-- 这张卡可以代替融合怪兽素材的其中1只来融合。这个时候，其他的融合素材必须是指定的融合素材。
function c50259460.initial_effect(c)
	-- 对应效果原文：“这张卡可以代替融合怪兽素材的其中1只来融合。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_FUSION_SUBSTITUTE)
	e1:SetCondition(c50259460.subcon)
	c:RegisterEffect(e1)
end
-- 作为代替融合素材的效果的适用条件：判断效果持有者（这张卡）当前是否位于手牌、主要怪兽区或墓地，若在这些区域则允许其作为代替融合素材参与融合。
function c50259460.subcon(e)
	return e:GetHandler():IsLocation(LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
end
