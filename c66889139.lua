--竜騎士ガイア
-- 效果：
-- 「暗黑骑士 盖亚」＋「诅咒之龙」
function c66889139.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加以「暗黑骑士 盖亚」和「诅咒之龙」为融合素材的融合召唤手续
	aux.AddFusionProcCode2(c,6368038,28279543,true,true)
end
