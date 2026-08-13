--シャドウ・グール
-- 效果：
-- 自己的墓地每存在1只怪兽，这张卡的攻击力上升100。
function c30778711.initial_effect(c)
	-- 自己的墓地每存在1只怪兽，这张卡的攻击力上升100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c30778711.value)
	c:RegisterEffect(e1)
end
-- 该函数计算这张卡的控制者墓地中怪兽卡的数量，并乘以100作为这张卡攻击力上升的数值。
function c30778711.value(e,c)
	-- 统计当前控制者墓地中满足怪兽卡类型的卡数量，再乘以100，返回攻击力上升值。
	return Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),LOCATION_GRAVE,0,nil,TYPE_MONSTER)*100
end
