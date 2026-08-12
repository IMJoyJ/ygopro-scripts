--タービン・ジェネクス
-- 效果：
-- ①：只要这张卡在怪兽区域存在，自己场上的「次世代」怪兽的攻击力上升400。
function c52222372.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，自己场上的「次世代」怪兽的攻击力上升400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果目标为场上所有「次世代」怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x2))
	e1:SetValue(400)
	c:RegisterEffect(e1)
end
