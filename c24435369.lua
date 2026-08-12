--マーメイド・ナイト
-- 效果：
-- ①：只要场上有「海」存在，这张卡在同1次的战斗阶段中可以作2次攻击。
function c24435369.initial_effect(c)
	-- 记录该卡片具有「海」这张场地卡的卡片密码
	aux.AddCodeList(c,22702055)
	-- ①：只要场上有「海」存在，这张卡在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetCondition(c24435369.dircon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件函数
function c24435369.dircon(e)
	-- 判断场地是否存在「海」
	return Duel.IsEnvironment(22702055)
end
