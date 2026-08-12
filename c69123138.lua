--ゼラ
-- 效果：
-- 「杰拉的仪式」降临。
function c69123138.initial_effect(c)
	-- 记录这张卡记有「杰拉的仪式」的卡名
	aux.AddCodeList(c,81756897)
	c:EnableReviveLimit()
end
