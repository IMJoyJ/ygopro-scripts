--暗黒火炎龍
-- 效果：
-- 「火炎草」＋「小龙」
function c17881964.initial_effect(c)
	c:EnableReviveLimit()
	-- 为「暗黑火炎龙」添加融合召唤手续：以卡号53293545（「火炎草」）和卡号75356564（「小龙」）作为融合素材，sub和insf均设为true。
	aux.AddFusionProcCode2(c,53293545,75356564,true,true)
end
