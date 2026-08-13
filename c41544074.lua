--カオス・ウィザード
-- 效果：
-- 「圣精灵」＋「黑魔族的幕帘」
function c41544074.initial_effect(c)
	c:EnableReviveLimit()
	-- 为混沌男巫添加融合召唤手续：以「圣精灵」（15025844）和「黑魔族的幕帘」（22026707）这2只怪兽作为融合素材进行融合召唤。
	aux.AddFusionProcCode2(c,15025844,22026707,true,true)
end
