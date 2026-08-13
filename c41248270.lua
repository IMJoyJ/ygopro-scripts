--トラフィックゴースト
-- 效果：
-- 怪兽3只
function c41248270.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续，需要3只任意怪兽作为连接素材（对应效果原文的“怪兽3只”）。
	aux.AddLinkProcedure(c,nil,3,3)
end
