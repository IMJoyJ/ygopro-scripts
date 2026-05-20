--幻獣クロスウィング
-- 效果：
-- 只要这张卡在墓地存在，场上的名字带有「幻兽」的怪兽的攻击力上升300。
function c71181155.initial_effect(c)
	-- 只要这张卡在墓地存在，场上的名字带有「幻兽」的怪兽的攻击力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果影响的对象为名字带有「幻兽」的怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1b))
	e1:SetValue(300)
	c:RegisterEffect(e1)
end
