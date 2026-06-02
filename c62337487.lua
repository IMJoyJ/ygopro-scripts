--要塞クジラ
-- 效果：
-- 借由「要塞鲸的誓言」降临。必须从场上或者手札，牺牲奉献等级合计为7个以上的卡。
function c62337487.initial_effect(c)
	-- 在卡片的关联卡列表中添加「要塞鲸的誓言」的卡片密码
	aux.AddCodeList(c,77454922)
	c:EnableReviveLimit()
end
