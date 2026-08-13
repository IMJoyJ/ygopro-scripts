--シュルブの魔導騎兵
-- 效果：
-- ←3 【灵摆】 3→
-- 【怪兽效果】
-- ①：这张卡只要在怪兽区域存在，不受灵摆怪兽以外的怪兽发动的效果影响。
function c23220863.initial_effect(c)
	-- 为该灵摆怪兽赋予灵摆召唤与灵摆卡发动等灵摆怪兽基本属性（默认同时注册灵摆卡的发动效果）。
	aux.EnablePendulumAttribute(c)
	-- ①：这张卡只要在怪兽区域存在，不受灵摆怪兽以外的怪兽发动的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(c23220863.efilter)
	c:RegisterEffect(e1)
end
-- 免疫判定过滤函数：当待判定效果te是怪兽效果且为发动的效果，并且该效果持有者不是灵摆怪兽时，返回true，使这张卡不受该效果影响；即只免疫“灵摆怪兽以外的怪兽发动的效果”。
function c23220863.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:IsActivated() and not te:GetOwner():IsType(TYPE_PENDULUM)
end
