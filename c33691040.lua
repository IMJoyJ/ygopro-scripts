--プラグティカル
-- 效果：
-- 「虎纹龙」＋「火焰毒蛇」
function c33691040.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以卡号42348802（「虎纹龙」）和卡号2830619（「火焰毒蛇」）为融合素材，且允许使用融合素材代用品、素材顺序不限。
	aux.AddFusionProcCode2(c,42348802,2830619,true,true)
end
