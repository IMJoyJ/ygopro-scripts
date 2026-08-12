--E・HERO ワイルドマン
-- 效果：
-- ①：这张卡只要在怪兽区域存在，不受陷阱卡的效果影响。
function c86188410.initial_effect(c)
	-- ①：这张卡只要在怪兽区域存在，不受陷阱卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(c86188410.efilter)
	c:RegisterEffect(e1)
end
-- 免疫效果的过滤函数，判定来源效果是否为陷阱卡的效果
function c86188410.efilter(e,te)
	return te:IsActiveType(TYPE_TRAP)
end
