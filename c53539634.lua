--クリッチー
-- 效果：
-- 「三眼怪」＋「黑森林的魔女」
function c53539634.initial_effect(c)
	c:EnableReviveLimit()
	-- 为「三眼小巫师」添加融合召唤手续，指定融合素材为「三眼怪」（78010363）和「黑森林的魔女」（26202165），并允许使用融合素材代用品及满足替代条件的融合素材。
	aux.AddFusionProcCode2(c,78010363,26202165,true,true)
end
