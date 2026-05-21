--修禅僧 ゲンドウ
-- 效果：
-- ①：只要这张卡在怪兽区域存在，场上的表侧攻击表示怪兽不能把效果发动。
-- ②：守备表示的这张卡不会成为卡的效果的对象，不会被效果破坏。
function c99000107.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，场上的表侧攻击表示怪兽不能把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetValue(c99000107.aclimit)
	c:RegisterEffect(e1)
	-- ②：守备表示的这张卡不会成为卡的效果的对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetCondition(c99000107.tgcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 判断发动效果的卡是否为场上表侧攻击表示的怪兽，以此来限制其效果发动
function c99000107.aclimit(e,re,tp)
	local tc=re:GetHandler()
	return tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() and tc:IsAttackPos() and re:IsActiveType(TYPE_MONSTER)
end
-- 判断自身是否处于守备表示，作为抗性效果的生效条件
function c99000107.tgcon(e)
	return e:GetHandler():IsDefensePos()
end
