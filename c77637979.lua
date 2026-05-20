--LANフォリンクス
-- 效果：
-- 怪兽2只
function c77637979.initial_effect(c)
	c:EnableReviveLimit()
	-- 为该卡添加连接召唤手续，需要2只怪兽作为素材
	aux.AddLinkProcedure(c,nil,2,2)
end
