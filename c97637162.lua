--ハンディ・ギャロップ
-- 效果：
-- ①：这张卡不能直接攻击。
-- ②：这张卡的攻击力上升双方基本分差的数值。
-- ③：自己基本分比对方多的场合，这张卡的攻击发生的对对方的战斗伤害由自己代受。
function c97637162.initial_effect(c)
	-- ①：这张卡不能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力上升双方基本分差的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c97637162.atkval)
	c:RegisterEffect(e2)
	-- ③：自己基本分比对方多的场合，这张卡的攻击发生的对对方的战斗伤害由自己代受。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	e3:SetCondition(c97637162.rfcon)
	c:RegisterEffect(e3)
end
-- 定义攻击力上升数值的计算函数
function c97637162.atkval(e,c)
	-- 返回双方玩家当前基本分之差的绝对值
	return math.abs(Duel.GetLP(0)-Duel.GetLP(1))
end
-- 定义战斗伤害代受效果的生效条件函数
function c97637162.rfcon(e)
	local tp=e:GetHandlerPlayer()
	-- 验证自己基本分是否高于对方，且当前进行攻击的怪兽是这张卡自身
	return Duel.GetLP(tp)>Duel.GetLP(1-tp) and Duel.GetAttacker()==e:GetHandler()
end
