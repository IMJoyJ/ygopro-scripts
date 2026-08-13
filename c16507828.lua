--ブラキオレイドス
-- 效果：
-- 「双头恐龙王」＋「贪尸龙」
function c16507828.initial_effect(c)
	c:EnableReviveLimit()
	-- 为腕龙添加融合召唤手续：指定以‘双头恐龙王’（卡号94119974）与‘贪尸龙’（卡号38289717）作为融合素材，并启用对应的融合素材代用/代替规则。
	aux.AddFusionProcCode2(c,94119974,38289717,true,true)
end
