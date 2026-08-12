--伝説のフィッシャーマン
-- 效果：
-- ①：只要场上有「海」存在，场上的这张卡不受魔法卡的效果影响。
-- ②：只要场上有「海」存在，这张卡不会被作为攻击对象（自己场上只有被这个效果适用的怪兽存在的状态中对方的攻击变成对自己的直接攻击）。
function c3643300.initial_effect(c)
	-- 记录该卡具有「海」这张场地卡的卡片密码
	aux.AddCodeList(c,22702055)
	-- 只要场上有「海」存在，场上的这张卡不受魔法卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c3643300.econ)
	e1:SetValue(c3643300.efilter)
	c:RegisterEffect(e1)
	-- 只要场上有「海」存在，这张卡不会被作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c3643300.econ)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 检查场地上是否存在「海」
function c3643300.econ(e)
	-- 场地上存在「海」时条件满足
	return Duel.IsEnvironment(22702055)
end
-- 过滤掉对魔法卡的效果
function c3643300.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL)
end
