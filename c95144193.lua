--クワガー・ヘラクレス
-- 效果：
-- 「锹甲阿尔法」＋「大力独角仙」
function c95144193.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加以「锹甲阿尔法」和「大力独角仙」为融合素材的融合召唤手续
	aux.AddFusionProcCode2(c,60802233,52584282,true,true)
end
