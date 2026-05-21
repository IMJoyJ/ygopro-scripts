--雷神の怒り
-- 效果：
-- 「耳天使」＋「大雷电球」
function c9653271.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加以「耳天使」和「大雷电球」为素材的融合召唤手续，允许使用融合代替素材
	aux.AddFusionProcCode2(c,86088138,21817254,true,true)
end
