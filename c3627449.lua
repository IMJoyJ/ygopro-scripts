--ローガーディアン
-- 效果：
-- 借由「法理的祈祷」降临。必须从场上或者手札，牺牲奉献等级合计为7个以上的卡。
function c3627449.initial_effect(c)
	-- 记录该卡片效果依赖于「法理的祈祷」这张卡片，用于后续效果判定
	aux.AddCodeList(c,43694075)
	c:EnableReviveLimit()
end
