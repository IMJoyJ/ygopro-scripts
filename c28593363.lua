--深海に潜むサメ
-- 效果：
-- 「神鱼」＋「舌鱼」
function c28593363.initial_effect(c)
	c:EnableReviveLimit()
	-- 将该卡设为需要使用卡号为81386177和69572024的2只怪兽作为融合素材才能融合召唤
	aux.AddFusionProcCode2(c,81386177,69572024,true,true)
end
