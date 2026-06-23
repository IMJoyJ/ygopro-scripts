--デビル・ボックス
-- 效果：
-- 「杀人小丑」＋「梦幻小丑」
function c25655502.initial_effect(c)
	c:EnableReviveLimit()
	-- 融合召唤手续：使用卡号为93889755和13215230的2只怪兽为融合素材
	aux.AddFusionProcCode2(c,93889755,13215230,true,true)
end
