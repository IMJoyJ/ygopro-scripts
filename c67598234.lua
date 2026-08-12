--電影の騎士ガイアセイバー
-- 效果：
-- 怪兽2只以上
function c67598234.initial_effect(c)
	-- 为该卡添加连接召唤手续，素材要求为2只以上的怪兽
	aux.AddLinkProcedure(c,nil,2)
	c:EnableReviveLimit()
end
