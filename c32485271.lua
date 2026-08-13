--バラに棲む悪霊
-- 效果：
-- 「小精怪」＋「蛇椰树」
function c32485271.initial_effect(c)
	c:EnableReviveLimit()
	-- 为「栖身蔷薇的恶灵」添加融合召唤手续：指定融合素材为卡号41392891（「小精怪」）和卡号29802344（「蛇椰树」），并通过两个true参数开启融合素材代用及放宽素材条件，以对应原效果中的『「小精怪」＋「蛇椰树」』。
	aux.AddFusionProcCode2(c,41392891,29802344,true,true)
end
