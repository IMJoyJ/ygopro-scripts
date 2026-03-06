--深海の戦士
-- 效果：
-- 只要「海」在场上存在，这张卡不会受到魔法的效果。
function c24128274.initial_effect(c)
	-- 记录该卡具有「海」这张卡的编号，用于后续判断
	aux.AddCodeList(c,22702055)
	-- 只要「海」在场上存在，这张卡不会受到魔法的效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c24128274.econ)
	e1:SetValue(c24128274.efilter)
	c:RegisterEffect(e1)
end
-- 条件函数，判断场地是否存在编号为22702055的场地卡
function c24128274.econ(e)
	-- 检查当前场上是否存在编号为22702055的场地卡
	return Duel.IsEnvironment(22702055)
end
-- 过滤函数，判断效果是否作用于魔法卡类型
function c24128274.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL)
end
