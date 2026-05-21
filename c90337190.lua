--魚雷魚
-- 效果：
-- 当场上存在「海」时，这张卡不受魔法效果的影响。
function c90337190.initial_effect(c)
	-- 在卡片中记录其记有「海」的卡片密码
	aux.AddCodeList(c,22702055)
	-- 当场上存在「海」时，这张卡不受魔法效果的影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c90337190.econ)
	e1:SetValue(c90337190.efilter)
	c:RegisterEffect(e1)
end
-- 免疫效果的生效条件函数
function c90337190.econ(e)
	-- 检查当前场上是否存在「海」的环境
	return Duel.IsEnvironment(22702055)
end
-- 免疫效果的过滤函数，指定不受魔法卡的效果影响
function c90337190.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL)
end
