--カルボナーラ戦士
-- 效果：
-- 「磁力战士1号」＋「磁力战士2号」
function c54541900.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加以「磁力战士1号」和「磁力战士2号」为素材的融合召唤手续
	aux.AddFusionProcCode2(c,56342351,92731455,true,true)
end
