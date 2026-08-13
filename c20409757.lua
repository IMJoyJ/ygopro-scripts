--時読みの魔術師
-- 效果：
-- ←8 【灵摆】 8→
-- 自己场上没有怪兽存在的场合才能把这张卡发动。
-- ①：自己的灵摆怪兽进行战斗的场合，对方直到伤害步骤结束时陷阱卡不能发动。
-- ②：另一边的自己的灵摆区域没有「魔术师」卡或者「异色眼」卡存在的场合，这张卡的灵摆刻度变成4。
-- 【怪兽效果】
-- ①：只要这张卡在怪兽区域存在，1回合1次，自己的灵摆区域的卡不会被对方的效果破坏。
function c20409757.initial_effect(c)
	-- 为该卡启用灵摆召唤属性（可进行灵摆召唤、额外卡组表侧表示放置等），但不注册默认的灵摆卡“卡的发动”效果，因为本卡的灵摆发动条件需要额外判定“自己场上没有怪兽”，改由后续e1效果实现。
	aux.EnablePendulumAttribute(c,false)
	-- 自己场上没有怪兽存在的场合才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1160)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c20409757.condition)
	c:RegisterEffect(e1)
	-- ①：自己的灵摆怪兽进行战斗的场合，对方直到伤害步骤结束时陷阱卡不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(c20409757.aclimit)
	e2:SetCondition(c20409757.actcon)
	c:RegisterEffect(e2)
	-- ②：另一边的自己的灵摆区域没有「魔术师」卡或者「异色眼」卡存在的场合，这张卡的灵摆刻度变成4。
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
	-- ①：只要这张卡在怪兽区域存在，1回合1次，自己的灵摆区域的卡不会被对方的效果破坏。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(LOCATION_PZONE,0)
	e6:SetCountLimit(1)
	-- 将该保护效果的作用目标选择函数设为恒真，即己方所有灵摆区域的卡都能受到此保护。
	e6:SetTarget(aux.TRUE)
	e6:SetValue(c20409757.indval)
	c:RegisterEffect(e6)
end
-- 定义e1的发动条件函数：检查我方场上怪兽区域（主要怪兽区+额外怪兽区）的怪兽数量是否为0，若为0则允许发动。
function c20409757.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 取得我方主要怪兽区和额外怪兽区存在的卡数量，并判断是否为0，作为“自己场上没有怪兽”的条件判定。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 定义e2的适用条件：检测当前是否有我方控制的灵摆怪兽在进行战斗，无论是作为攻击方还是被攻击方。
function c20409757.actcon(e)
	local tp=e:GetHandlerPlayer()
	-- 获取当前战斗阶段的攻击怪兽，存入变量tc。
	local tc=Duel.GetAttacker()
	if not tc then return false end
	-- 如果攻击怪兽不是我方控制，则把tc换成被攻击目标，以便判断我方怪兽是否正在参与战斗。
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	return tc and tc:IsControler(tp) and tc:IsType(TYPE_PENDULUM)
end
-- 定义禁止发动的判定值：对方发动的效果必须是陷阱卡的“卡的发动”（EFFECT_TYPE_ACTIVATE），即只禁止陷阱卡卡的发动。
function c20409757.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 定义过滤器：检查卡片是否属于「魔术师」系列（0x98）或「异色眼」系列（0x99）。
function c20409757.slfilter(c)
	return c:IsSetCard(0x98,0x99)
end
-- 定义e4/e5的刻度变化条件：自己的另一个灵摆区域不存在「魔术师」卡或「异色眼」卡时，条件成立。
function c20409757.slcon(e)
	-- 在自己的灵摆区域（排除自身）中检索是否存在任意1张满足「魔术师」或「异色眼」系列的卡；若不存在则返回true。
	return not Duel.IsExistingMatchingCard(c20409757.slfilter,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,e:GetHandler())
end
-- 定义该保护效果的判定函数：当破坏原因为效果破坏，且破坏方为这张卡控制者的对手时返回true，允许该次破坏被无效。
function c20409757.indval(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and rp==1-e:GetHandlerPlayer()
end
