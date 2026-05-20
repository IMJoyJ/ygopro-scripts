--戦場の死装束
-- 效果：
-- 「音女」＋「斩首的美女」
function c56413937.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置以「音女」和「斩首的美女」为融合素材的融合召唤手续
	aux.AddFusionProcCode2(c,38942059,16899564,true,true)
end
