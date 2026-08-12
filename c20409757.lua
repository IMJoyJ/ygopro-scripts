--時読みの魔術師
-- 效果：
-- ←8 【灵摆】 8→
-- 自己场上没有怪兽存在的场合才能把这张卡发动。
-- ①：自己的灵摆怪兽进行战斗的场合，对方直到伤害步骤结束时陷阱卡不能发动。
-- ②：另一边的自己的灵摆区域没有「魔术师」卡或者「异色眼」卡存在的场合，这张卡的灵摆刻度变成4。
-- 【怪兽效果】
-- ①：只要这张卡在怪兽区域存在，1回合1次，自己的灵摆区域的卡不会被对方的效果破坏。
function c20409757.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，但不注册其发动效果
	aux.EnablePendulumAttribute(c,false)
	-- 自己场上没有怪兽存在的场合才能把这张卡发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1160)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c20409757.condition)
	c:RegisterEffect(e1)
	-- 自己的灵摆怪兽进行战斗的场合，对方直到伤害步骤结束时陷阱卡不能发动
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(c20409757.aclimit)
	e2:SetCondition(c20409757.actcon)
	c:RegisterEffect(e2)
	-- 另一边的自己的灵摆区域没有「魔术师」卡或者「异色眼」卡存在的场合，这张卡的灵摆刻度变成4
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CHANGE_LSCALE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCondition(c20409757.slcon)
	e4:SetValue(4)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(e5)
	-- 只要这张卡在怪兽区域存在，1回合1次，自己的灵摆区域的卡不会被对方的效果破坏
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(LOCATION_PZONE,0)
	e6:SetCountLimit(1)
	-- 设置效果目标为所有卡
	e6:SetTarget(aux.TRUE)
	e6:SetValue(c20409757.indval)
	c:RegisterEffect(e6)
end
-- 判断自己场上是否没有怪兽
function c20409757.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否没有怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 判断攻击怪兽是否为自己的灵摆怪兽
function c20409757.actcon(e)
	local tp=e:GetHandlerPlayer()
	-- 获取当前攻击怪兽
	local tc=Duel.GetAttacker()
	if not tc then return false end
	-- 若攻击怪兽为对方控制，则获取对方攻击目标
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	return tc and tc:IsControler(tp) and tc:IsType(TYPE_PENDULUM)
end
-- 判断效果是否为陷阱卡的发动
function c20409757.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 判断卡是否为「魔术师」或「异色眼」系列
function c20409757.slfilter(c)
	return c:IsSetCard(0x98,0x99)
end
-- 判断另一边的自己的灵摆区域是否存在「魔术师」或「异色眼」卡
function c20409757.slcon(e)
	-- 判断另一边的自己的灵摆区域是否存在「魔术师」或「异色眼」卡
	return not Duel.IsExistingMatchingCard(c20409757.slfilter,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,e:GetHandler())
end
-- 判断破坏原因是否为效果且破坏者为对方
function c20409757.indval(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and rp==1-e:GetHandlerPlayer()
end
