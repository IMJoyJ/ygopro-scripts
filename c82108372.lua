--ムドラ
-- 效果：
-- 自己墓地里每存在1只天使族怪兽，这张卡的攻击力上升200点。
function c82108372.initial_effect(c)
	-- 自己墓地里每存在1只天使族怪兽，这张卡的攻击力上升200点。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c82108372.val)
	c:RegisterEffect(e1)
end
-- 定义计算攻击力上升数值的数值函数
function c82108372.val(e,c)
	-- 获取自己墓地中天使族怪兽的数量并乘以200作为攻击力上升值
	return Duel.GetMatchingGroupCount(Card.IsRace,c:GetControler(),LOCATION_GRAVE,0,nil,RACE_FAIRY)*200
end
