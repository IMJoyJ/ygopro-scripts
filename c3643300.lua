--伝説のフィッシャーマン
-- 效果：
-- ①：只要场上有「海」存在，场上的这张卡不受魔法卡的效果影响。
-- ②：只要场上有「海」存在，这张卡不会被作为攻击对象（自己场上只有被这个效果适用的怪兽存在的状态中对方的攻击变成对自己的直接攻击）。
function c3643300.initial_effect(c)
	-- 记录这张卡（传说的渔人）的文本中记载着卡号22702055的「海」这一卡名，使相关检索/联动效果能识别该卡。
	aux.AddCodeList(c,22702055)
	-- ①：只要场上有「海」存在，场上的这张卡不受魔法卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c3643300.econ)
	e1:SetValue(c3643300.efilter)
	c:RegisterEffect(e1)
	-- ②：只要场上有「海」存在，这张卡不会被作为攻击对象（自己场上只有被这个效果适用的怪兽存在的状态中对方的攻击变成对自己的直接攻击）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c3643300.econ)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 定义条件函数econ，返回“场上有「海」存在”的条件是否成立（通过Duel.IsEnvironment检测卡号22702055），作为效果①和②的适用前提。
function c3643300.econ(e)
	-- 调用Duel.IsEnvironment检测场上是否存在卡号22702055的「海」（默认检查场地魔法区域和魔法陷阱区域的表侧表示卡），若存在则条件成立。
	return Duel.IsEnvironment(22702055)
end
-- 定义效果免疫的过滤函数efilter，判断施加于本卡的效果te是否为魔法卡效果，若是魔法卡（TYPE_SPELL）则返回true，使本卡不受该效果影响。
function c3643300.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL)
end
