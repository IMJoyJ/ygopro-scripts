--紅陽鳥
-- 效果：
-- 「圣鸟」＋「天空猎手」
function c46696593.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续，使用卡号为75582395和10202894的两只怪兽作为融合素材
	aux.AddFusionProcCode2(c,75582395,10202894,true,true)
end
