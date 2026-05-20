--音楽家の帝王
-- 效果：
-- 「黑森林的魔女」＋「高等女祭司」
function c56907389.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加以「黑森林的魔女」和「高等女祭司」为融合素材的融合召唤手续
	aux.AddFusionProcCode2(c,78010363,17358176,true,true)
end
