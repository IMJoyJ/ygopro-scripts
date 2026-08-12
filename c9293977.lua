--メタル・ドラゴン
-- 效果：
-- 「钢铁巨神像」＋「下级龙」
function c9293977.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加以「钢铁巨神像」和「下级龙」为融合素材的融合召唤手续
	aux.AddFusionProcCode2(c,29172562,55444629,true,true)
end
