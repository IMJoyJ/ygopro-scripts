--千年竜
-- 效果：
-- 「时间魔术师」＋「宝贝龙」
function c41462083.initial_effect(c)
	c:EnableReviveLimit()
	-- 为千年龙添加融合召唤手续，指定融合素材为「时间魔术师」（71625222）和「宝贝龙」（88819587），使满足该素材组合时可作为融合怪兽进行融合召唤。
	aux.AddFusionProcCode2(c,71625222,88819587,true,true)
end
