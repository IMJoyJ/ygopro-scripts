--暗黒火炎龍
-- 效果：
-- 「火炎草」＋「小龙」
function c17881964.initial_effect(c)
	c:EnableReviveLimit()
	-- 将该卡设为需要使用卡号为53293545和75356564的2只怪兽作为融合素材才能融合召唤
	aux.AddFusionProcCode2(c,53293545,75356564,true,true)
end
