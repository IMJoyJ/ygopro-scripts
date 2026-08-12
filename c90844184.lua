--ガルマソード
-- 效果：
-- 「伽玛剑的誓言」降临。
function c90844184.initial_effect(c)
	-- 将「伽玛剑的誓言」注册为本卡片记载的卡名
	aux.AddCodeList(c,78577570)
	c:EnableReviveLimit()
end
