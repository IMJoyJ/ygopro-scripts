--裁きを下す女帝
-- 效果：
-- 「女王的影武者」＋「响女」
function c15237615.initial_effect(c)
	c:EnableReviveLimit()
	-- 为该卡添加融合召唤手续：使用卡号5901497（「女王的影武者」）和卡号64501875（「响女」）作为融合素材，且sub和insf参数均设为true（表示允许相应的融合素材代用/融合手续选项）。
	aux.AddFusionProcCode2(c,5901497,64501875,true,true)
end
