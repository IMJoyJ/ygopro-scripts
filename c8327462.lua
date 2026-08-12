--デス・バード
-- 效果：
-- 「橐蜚」＋「骷髅寺院」
function c8327462.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加以「橐蜚」和「骷髅寺院」为融合素材的融合召唤手续
	aux.AddFusionProcCode2(c,3170832,732302,true,true)
end
