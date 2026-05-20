--水陸両用バグロス Mk－3
-- 效果：
-- 当场上存在「海」时，这张卡可以对对方进行直接攻击。
function c64342551.initial_effect(c)
	-- 将「海」的卡片密码（22702055）加入到这张卡记载的卡片列表中
	aux.AddCodeList(c,22702055)
	-- 当场上存在「海」时，这张卡可以对对方进行直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(c64342551.dircon)
	c:RegisterEffect(e1)
end
-- 定义直接攻击效果的允许条件函数
function c64342551.dircon(e)
	-- 检查当前游戏环境中是否存在「海」
	return Duel.IsEnvironment(22702055)
end
