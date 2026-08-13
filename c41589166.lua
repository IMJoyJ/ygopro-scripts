--天下人 紫炎
-- 效果：
-- 这张卡不受陷阱卡的效果影响。
function c41589166.initial_effect(c)
	-- 这张卡不受陷阱卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(c41589166.efilter)
	c:RegisterEffect(e1)
end
-- 免疫效果的过滤函数：若试图对这张卡生效的效果是陷阱卡效果，则返回真，使这张卡不受该陷阱卡效果影响。
function c41589166.efilter(e,te)
	return te:IsActiveType(TYPE_TRAP)
end
