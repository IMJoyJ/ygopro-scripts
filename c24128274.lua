--深海の戦士
-- 效果：
-- 只要「海」在场上存在，这张卡不会受到魔法的效果。
function c24128274.initial_effect(c)
	-- 将卡号22702055（「海」）登记为本卡关联卡名，便于后续效果条件判断。
	aux.AddCodeList(c,22702055)
	-- 对应效果原文：“只要「海」在场上存在，这张卡不会受到魔法的效果。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c24128274.econ)
	e1:SetValue(c24128274.efilter)
	c:RegisterEffect(e1)
end
-- 定义该效果适用的条件：当场上存在「海」时，免疫效果开始适用。
function c24128274.econ(e)
	-- 检测当前场上是否有效力中的「海」（通过Duel.IsEnvironment），存在则返回true，使条件成立。
	return Duel.IsEnvironment(22702055)
end
-- 定义免疫过滤函数：若即将适用的效果是魔法卡效果（te:IsActiveType(TYPE_SPELL)），则返回true，表示该效果被免疫。
function c24128274.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL)
end
