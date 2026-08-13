--森の住人 ウダン
-- 效果：
-- 场上每存在1只表侧表示的植物族怪兽，这张卡的攻击力上升100。
function c42883273.initial_effect(c)
	-- 场上每存在1只表侧表示的植物族怪兽，这张卡的攻击力上升100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c42883273.value)
	c:RegisterEffect(e1)
end
-- 过滤器：判断怪兽是否为表侧表示且属于植物族，用于筛选场上符合条件的植物族怪兽。
function c42883273.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- 数值函数：统计场上表侧表示的植物族怪兽数量，并乘以100作为这张卡的攻击力上升数值。
function c42883273.value(e,c)
	-- 返回场上所有表侧表示植物族怪兽的数量乘以100，即这张卡的攻击力上升值。
	return Duel.GetMatchingGroupCount(c42883273.filter,0,LOCATION_MZONE,LOCATION_MZONE,nil)*100
end
