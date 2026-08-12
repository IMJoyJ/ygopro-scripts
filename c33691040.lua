--プラグティカル
-- 效果：
-- 「虎纹龙」＋「火焰毒蛇」
function c33691040.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置该卡的融合召唤手续，使用卡号为42348802和2830619的两只怪兽作为融合素材
	aux.AddFusionProcCode2(c,42348802,2830619,true,true)
end
