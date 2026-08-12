--シュルブの魔導騎兵
-- 效果：
-- ←3 【灵摆】 3→
-- 【怪兽效果】
-- ①：这张卡只要在怪兽区域存在，不受灵摆怪兽以外的怪兽发动的效果影响。
function c23220863.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
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
-- 定义效果过滤器函数，用于判断是否免疫某个效果：当效果来源是怪兽类型且已发动，并且其拥有者不是灵摆怪兽时，则免疫该效果
function c23220863.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:IsActivated() and not te:GetOwner():IsType(TYPE_PENDULUM)
end
