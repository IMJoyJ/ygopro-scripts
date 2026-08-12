--ハングリーバーガー
-- 效果：
-- 「汉堡的食谱」降临
function c30243636.initial_effect(c)
	-- 记录该卡记载了仪式魔法「汉堡的食谱」的卡名，便于被其他相关卡片检索
	aux.AddCodeList(c,80811661)
	c:EnableReviveLimit()
end
