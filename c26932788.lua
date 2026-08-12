--ジャベリンビートル
-- 效果：
-- 借由「标枪甲虫的契约」降临。必须从场上或者手札，牺牲奉献等级合计为8个以上的卡。
function c26932788.initial_effect(c)
	-- 记录卡片效果中记载了「标枪甲虫的契约」的卡名
	aux.AddCodeList(c,41182875)
	c:EnableReviveLimit()
end
