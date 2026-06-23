--機械王
-- 效果：
-- 每1只在场上表侧表示存在的机械族怪兽，这张卡的攻击力上升100。
function c46700124.initial_effect(c)
	-- 每1只在场上表侧表示存在的机械族怪兽，这张卡的攻击力上升100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c46700124.val)
	c:RegisterEffect(e1)
end
-- 计算满足条件的机械族怪兽数量并乘以100作为攻击力加成
function c46700124.val(e,c)
	-- 检索场上表侧表示的机械族怪兽数量，并乘以100作为攻击力提升值
	return Duel.GetMatchingGroupCount(c46700124.filter,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,nil)*100
end
-- 过滤函数，用于判断怪兽是否为表侧表示的机械族怪兽
function c46700124.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
