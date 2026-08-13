--深海に潜むサメ
-- 效果：
-- 「神鱼」＋「舌鱼」
function c28593363.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以「神鱼」（81386177）和「舌鱼」（69572024）作为融合素材；sub=true表示允许使用融合素材代用怪兽，insf=true表示允许无视部分融合素材限制，对应效果原文「神鱼」＋「舌鱼」的融合召唤条件。
	aux.AddFusionProcCode2(c,81386177,69572024,true,true)
end
