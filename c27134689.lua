--マスター・オブ・OZ
-- 效果：
-- 「巨大树熊」＋「死亡袋鼠」
function c27134689.initial_effect(c)
	c:EnableReviveLimit()
	-- 为「OZ之主」添加融合召唤手续，融合素材为「巨大树熊」（42129512）与「死亡袋鼠」（78613627），并启用融合素材代用等宽松处理。
	aux.AddFusionProcCode2(c,42129512,78613627,true,true)
end
