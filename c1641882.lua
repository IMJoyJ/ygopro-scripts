--フュージョニスト
-- 效果：
-- 「小天使」＋「催眠羊」
function c1641882.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：指定融合素材为卡号38142739的「小天使」和卡号83464209的「催眠羊」，参数true,true表示允许使用融合素材代用品并启用对应的融合素材规则。
	aux.AddFusionProcCode2(c,38142739,83464209,true,true)
end
