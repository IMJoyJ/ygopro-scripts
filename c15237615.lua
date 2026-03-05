--裁きを下す女帝
-- 效果：
-- 「女王的影武者」＋「响女」
function c15237615.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置该卡的融合召唤手续，使用卡号为5901497和64501875的2只怪兽作为融合素材
	aux.AddFusionProcCode2(c,5901497,64501875,true,true)
end
