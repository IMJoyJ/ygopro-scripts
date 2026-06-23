--カオス・ソルジャー
-- 效果：
-- 「混沌的仪式」降临。
function c5405694.initial_effect(c)
	-- 将「混沌的仪式」(55761792)加入该卡的关联卡片密码列表中
	aux.AddCodeList(c,55761792)
	c:EnableReviveLimit()
end
