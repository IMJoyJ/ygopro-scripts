--スケルゴン
-- 效果：
-- 「美杜莎的亡灵」＋「暗黑之龙王」
function c32355828.initial_effect(c)
	c:EnableReviveLimit()
	-- 为“骸骨龙”添加融合召唤手续：以卡号29491031（美杜莎的亡灵）和卡号87564352（暗黑之龙王）作为融合素材，并启用对应的融合素材设定，使该卡可以通过融合召唤方式特殊召唤。
	aux.AddFusionProcCode2(c,29491031,87564352,true,true)
end
