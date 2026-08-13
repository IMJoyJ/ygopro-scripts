--マーメイド・ナイト
-- 效果：
-- ①：只要场上有「海」存在，这张卡在同1次的战斗阶段中可以作2次攻击。
function c24435369.initial_effect(c)
	-- 调用aux.AddCodeList(c,22702055)，记录这张卡（人鱼骑士）上记载着卡名「海」（卡号22702055），以便相关联动或检索判断。
	aux.AddCodeList(c,22702055)
	-- ①：只要场上有「海」存在，这张卡在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetCondition(c24435369.dircon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
-- 定义条件函数dircon，用于判断这张卡能否获得额外攻击次数的效果，即当前场上是否存在「海」。
function c24435369.dircon(e)
	-- 调用Duel.IsEnvironment(22702055)，检查当前场上生效的场地卡是否为「海」（卡号22702055），是则条件满足，返回true。
	return Duel.IsEnvironment(22702055)
end
