--チャクラ
-- 效果：
-- 借由「查克拉的复活」降临。必须从场上或者手札，牺牲奉献等级合计为7个以上的卡。
function c65393205.initial_effect(c)
	aux.AddCodeList(c,39399168)
	c:EnableReviveLimit()
end
