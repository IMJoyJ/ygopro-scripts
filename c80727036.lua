--黒き人食い鮫
-- 效果：
-- 「深海切割手」＋「杀人污泥」＋「海原的女战士」
function c80727036.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加以「深海切割手」＋「杀人污泥」＋「海原的女战士」为融合素材的融合召唤手续
	aux.AddFusionProcCode3(c,71746462,65623423,17968114,true,true)
end
