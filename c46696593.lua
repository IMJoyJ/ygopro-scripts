--紅陽鳥
-- 效果：
-- 「圣鸟」＋「天空猎手」
function c46696593.initial_effect(c)
	c:EnableReviveLimit()
	-- 为「红阳鸟」添加融合召唤手续：以卡号75582395（「圣鸟」）和卡号10202894（「天空猎手」）为融合素材，sub=true允许使用融合素材代用品，insf=true表示该融合召唤手续为效果外文本、不进入连锁。
	aux.AddFusionProcCode2(c,75582395,10202894,true,true)
end
