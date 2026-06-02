--マジシャン・オブ・ブラックカオス
-- 效果：
-- 「混沌-黑魔术的仪式」降临
function c30208479.initial_effect(c)
	-- 记录该卡记载了仪式魔法「混沌-黑魔术的仪式」的卡名，便于被其他相关卡片检索
	aux.AddCodeList(c,76792184)
	c:EnableReviveLimit()
end
