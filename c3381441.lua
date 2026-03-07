--墓守の巫女
-- 效果：
-- 只要这张卡在场上表侧表示存在，场地变成「王家长眠之谷」。场地魔法卡表侧表示存在的场合，这个效果不适用。此外，只要这张卡在场上表侧表示存在，场上的名字带有「守墓」的怪兽的攻击力·守备力上升200。
function c3381441.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，场地变成「王家长眠之谷」。场地魔法卡表侧表示存在的场合，这个效果不适用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CHANGE_ENVIRONMENT)
	e1:SetValue(47355498)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上表侧表示存在，场上的名字带有「守墓」的怪兽的攻击力上升200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果目标为名字带有「守墓」的怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x2e))
	e2:SetValue(200)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上表侧表示存在，场上的名字带有「守墓」的怪兽的守备力上升200。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果目标为名字带有「守墓」的怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x2e))
	e3:SetValue(200)
	c:RegisterEffect(e3)
end
