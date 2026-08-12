--ミノケンタウロス
-- 效果：
-- 「牛头人」＋「人马兽」
function c94905343.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加以「牛头人」和「人马兽」为融合素材的融合召唤手续
	aux.AddFusionProcCode2(c,5053103,68516705,true,true)
end
