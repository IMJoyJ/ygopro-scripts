--バラに棲む悪霊
-- 效果：
-- 「小精怪」＋「蛇椰树」
function c32485271.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置该卡的融合召唤手续，使用卡号为41392891和29802344的2只怪兽作为融合素材
	aux.AddFusionProcCode2(c,41392891,29802344,true,true)
end
