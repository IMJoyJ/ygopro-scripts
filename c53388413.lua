--総剣司令 ガトムズ
-- 效果：
-- 只要这张卡在场上表侧表示存在，自己场上表侧表示存在的名字带有「剑士」的怪兽的攻击力上升400。
function c53388413.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，自己场上表侧表示存在的名字带有「剑士」的怪兽的攻击力上升 400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	-- 设置目标筛选条件，指定只选择名字带有「剑士」的怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xd))
	e1:SetValue(400)
	c:RegisterEffect(e1)
end
