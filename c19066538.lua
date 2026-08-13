--轟きの大海蛇
-- 效果：
-- 「魔法灯」＋「兵主部」
function c19066538.initial_effect(c)
	c:EnableReviveLimit()
	-- 为该怪兽添加融合召唤手续，融合素材为卡号98049915的「魔法灯」和卡号2118022的「兵主部」，满足条件即可进行融合召唤。
	aux.AddFusionProcCode2(c,98049915,2118022,true,true)
end
