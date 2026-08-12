--金色の魔象
-- 效果：
-- 「美杜莎的亡灵」＋「龙僵尸」
function c54622031.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置以「美杜莎的亡灵」和「龙僵尸」为融合素材的融合召唤手续
	aux.AddFusionProcCode2(c,29491031,66672569,true,true)
end
