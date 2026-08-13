--魅幽鳥
-- 效果：
-- ①：这张卡只要在主要怪兽区域存在，得到那个位置的以下效果。
-- ●左端：这张卡的攻击力·守备力上升1000。
-- ●右端：这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
-- ●中央：这张卡不会成为对方的效果的对象，不会被对方的效果破坏。
-- ●那以外：和这张卡相同纵列的怪兽不能把效果发动。
function c15419596.initial_effect(c)
	-- ①：这张卡只要在主要怪兽区域存在，得到那个位置的以下效果。●左端：这张卡的攻击力·守备力上升1000。（此段实现攻击力上升部分）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c15419596.atkcon)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- ●右端：这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c15419596.eacon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ●中央：这张卡不会成为对方的效果的对象，不会被对方的效果破坏。（此段实现‘不会成为对方的效果的对象’部分）
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c15419596.indcon)
	-- 将本效果的判定函数设为 aux.tgoval，使对方的效果不能选择这张卡为对象，对应‘不会成为对方的效果的对象’。
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	-- ●中央：这张卡不会成为对方的效果的对象，不会被对方的效果破坏。（此段实现‘不会被对方的效果破坏’部分）
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(c15419596.indcon)
	-- 将本效果的判定函数设为 aux.indoval，使这张卡不会被对方的效果破坏，对应‘不会被对方的效果破坏’。
	e5:SetValue(aux.indoval)
	c:RegisterEffect(e5)
	-- ●那以外：和这张卡相同纵列的怪兽不能把效果发动。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetCode(EFFECT_CANNOT_ACTIVATE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(1,1)
	e6:SetCondition(c15419596.actcon)
	e6:SetValue(c15419596.aclimit)
	c:RegisterEffect(e6)
end
-- 判定这张卡是否位于主要怪兽区域的最左端（序列0），只有满足时攻击力上升效果适用。
function c15419596.atkcon(e)
	return e:GetHandler():GetSequence()==0
end
-- 判定这张卡是否位于主要怪兽区域的最右端（序列4），只有满足时才能获得追加攻击效果。
function c15419596.eacon(e)
	return e:GetHandler():GetSequence()==4
end
-- 判定这张卡是否位于主要怪兽区域的中央（序列2），只有满足时才能获得‘不会成为对方效果对象/不会被对方效果破坏’的抗性。
function c15419596.indcon(e)
	return e:GetHandler():GetSequence()==2
end
-- 判定这张卡是否位于主要怪兽区域的‘那以外’位置（序列1或3），这是‘相同纵列的怪兽不能发动效果’的适用条件。
function c15419596.actcon(e)
	local c=e:GetHandler()
	return c:GetSequence()==1 or c:GetSequence()==3
end
-- 发动效果判定：若发动效果的卡为与此卡同一纵列且位于主要怪兽区域的怪兽，则该效果不能发动，实现‘和这张卡相同纵列的怪兽不能把效果发动’。
function c15419596.aclimit(e,re,tp)
	local tc=re:GetHandler()
	return tc:IsLocation(LOCATION_MZONE) and re:IsActiveType(TYPE_MONSTER) and e:GetHandler():GetColumnGroup():IsContains(tc)
end
