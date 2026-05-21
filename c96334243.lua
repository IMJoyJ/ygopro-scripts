--テセウスの魔棲物
-- 效果：
-- 调整×2
function c96334243.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，需要2只调整怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionType,TYPE_TUNER),2,true)
end
