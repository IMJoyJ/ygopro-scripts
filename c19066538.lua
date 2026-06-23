--轟きの大海蛇
-- 效果：
-- 「魔法灯」＋「兵主部」
function c19066538.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续，使用卡号为98049915和2118022的2只怪兽为融合素材
	aux.AddFusionProcCode2(c,98049915,2118022,true,true)
end
