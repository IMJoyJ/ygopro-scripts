--D・ラジオン
-- 效果：
-- 这张卡得到这张卡的表示形式的以下效果。
-- ●攻击表示：只要这张卡在场上表侧表示存在，自己场上存在的名字带有「变形斗士」的怪兽的攻击力上升800。
-- ●守备表示：只要这张卡在场上表侧表示存在，自己场上存在的名字带有「变形斗士」的怪兽的守备力上升1000。
function c55119278.initial_effect(c)
	-- ●攻击表示：只要这张卡在场上表侧表示存在，自己场上存在的名字带有「变形斗士」的怪兽的攻击力上升800。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(c55119278.cona)
	-- 设置效果影响的目标为名字带有「变形斗士」的怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x26))
	e1:SetValue(800)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetCondition(c55119278.cond)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
end
-- 检查此卡是否为攻击表示，作为攻击力上升效果的生效条件
function c55119278.cona(e)
	return e:GetHandler():IsAttackPos()
end
-- 检查此卡是否为守备表示，作为守备力上升效果的生效条件
function c55119278.cond(e)
	return e:GetHandler():IsDefensePos()
end
