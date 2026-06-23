--海神の巫女
-- 效果：
-- 只要这张卡在场上表侧表示存在，场地变成「海」。场地魔法卡表侧表示存在的场合，这个效果不适用。
function c17214465.initial_effect(c)
	-- 记录这张卡具有「海」这张场地魔法卡的代码，用于效果判定
	aux.AddCodeList(c,22702055)
	-- 只要这张卡在场上表侧表示存在，场地变成「海」。场地魔法卡表侧表示存在的场合，这个效果不适用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CHANGE_ENVIRONMENT)
	e1:SetValue(22702055)
	c:RegisterEffect(e1)
end
