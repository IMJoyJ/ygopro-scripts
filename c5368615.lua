--スチームジャイロイド
-- 效果：
-- 「旋翼机人」＋「蒸汽机人」
function c5368615.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，用卡号为 18325492 和 44729197 的 2 只怪兽为融合素材
	aux.AddFusionProcCode2(c,18325492,44729197,true,true)
end
