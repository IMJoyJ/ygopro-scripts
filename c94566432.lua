--カイザー・ドラゴン
-- 效果：
-- 「守城的翼龙」＋「妖精龙」
function c94566432.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加以「守城的翼龙」和「妖精龙」为融合素材的融合召唤手续
	aux.AddFusionProcCode2(c,87796900,20315854,true,true)
end
