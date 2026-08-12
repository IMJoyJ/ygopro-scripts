--トラフィックゴースト
-- 效果：
-- 怪兽3只
function c41248270.initial_effect(c)
	c:EnableReviveLimit()
	-- 连接召唤手续：使用恰好3只怪兽作为连接素材
	aux.AddLinkProcedure(c,nil,3,3)
end
