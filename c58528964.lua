--フレイム・ゴースト
-- 效果：
-- 「白骨」＋「岩浆人」
function c58528964.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加以「白骨」和「岩浆人」为素材的融合召唤手续
	aux.AddFusionProcCode2(c,32274490,40826495,true,true)
end
