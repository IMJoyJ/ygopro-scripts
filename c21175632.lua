--聖女ジャンヌ
-- 效果：
-- 「大慈大悲的修女」＋「堕天使 玛丽」
function c21175632.initial_effect(c)
	c:EnableReviveLimit()
	-- 将该卡设为需要使用卡号为84080938和57579381的怪兽作为融合素材的融合怪兽，并且可以作为融合召唤的替代效果
	aux.AddFusionProcCode2(c,84080938,57579381,true,true)
end
