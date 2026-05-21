--メカ・ザウルス
-- 效果：
-- 「炸弹先生」＋「双头恐龙王」
function c89112729.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加以「炸弹先生」和「双头恐龙王」为融合素材的融合召唤手续
	aux.AddFusionProcCode2(c,70138455,94119974,true,true)
end
