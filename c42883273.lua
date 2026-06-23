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
-- 过滤函数，用于判断目标怪兽是否为表侧表示的植物族怪兽
function c42883273.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- 计算满足条件的怪兽数量并乘以100作为攻击力提升值
function c42883273.value(e,c)
	-- 检索满足条件的卡片组并计算其数量
	return Duel.GetMatchingGroupCount(c42883273.filter,0,LOCATION_MZONE,LOCATION_MZONE,nil)*100
end
