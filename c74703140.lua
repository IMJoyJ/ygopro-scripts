--裁きの鷹
-- 效果：
-- 「苍翼冠鸟」＋「胖鸡」
function c74703140.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加以「苍翼冠鸟」和「胖鸡」为素材的融合召唤手续
	aux.AddFusionProcCode2(c,41396436,7805359,true,true)
end
