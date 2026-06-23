--マスター・オブ・OZ
-- 效果：
-- 「巨大树熊」＋「死亡袋鼠」
function c27134689.initial_effect(c)
	c:EnableReviveLimit()
	-- 使用卡号为42129512和78613627的2只怪兽作为融合素材进行融合召唤
	aux.AddFusionProcCode2(c,42129512,78613627,true,true)
end
