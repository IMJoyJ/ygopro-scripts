--スケルゴン
-- 效果：
-- 「美杜莎的亡灵」＋「暗黑之龙王」
function c32355828.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续，使用卡号为29491031和87564352的2只怪兽为融合素材
	aux.AddFusionProcCode2(c,29491031,87564352,true,true)
end
