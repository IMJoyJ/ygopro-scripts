--魔装騎士ドラゴネス
-- 效果：
-- 「铠甲剑尾战士」＋「独眼盾龙」
function c70681994.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加以「铠甲剑尾战士」和「独眼盾龙」为融合素材的融合召唤手续
	aux.AddFusionProcCode2(c,53153481,33064647,true,true)
end
