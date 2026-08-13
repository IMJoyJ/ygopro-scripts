--ローガーディアン
-- 效果：
-- 借由「法理的祈祷」降临。必须从场上或者手札，牺牲奉献等级合计为7个以上的卡。
function c3627449.initial_effect(c)
	-- 将卡号43694075（「法理的祈祷」）登记为此卡上记载的卡名，用于后续相关效果判定。
	aux.AddCodeList(c,43694075)
	c:EnableReviveLimit()
end
