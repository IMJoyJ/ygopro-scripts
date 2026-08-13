--スチームジャイロイド
-- 效果：
-- 「旋翼机人」＋「蒸汽机人」
function c5368615.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续，融合素材指定为「旋翼机人」(18325492)和「蒸汽机人」(44729197)，并允许使用代替素材及融合素材代用怪兽（即非指定素材也可视情况代替）。
	aux.AddFusionProcCode2(c,18325492,44729197,true,true)
end
