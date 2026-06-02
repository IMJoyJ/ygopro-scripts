--要塞クジラ
-- 效果：
-- 借由「要塞鲸的誓言」降临。必须从场上或者手札，牺牲奉献等级合计为7个以上的卡。
function c62337487.initial_effect(c)
	aux.AddCodeList(c,77454922)
	c:EnableReviveLimit()
end
