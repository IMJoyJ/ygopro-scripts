--アンデット・ウォーリアー
-- 效果：
-- 「白骨」＋「格斗战士 阿提米特」
function c31339260.initial_effect(c)
	c:EnableReviveLimit()
	-- 将该卡设为需要使用卡号为32274490和55550921的2只怪兽作为融合素材才能融合召唤
	aux.AddFusionProcCode2(c,32274490,55550921,true,true)
end
