--アンデット・ウォーリアー
-- 效果：
-- 「白骨」＋「格斗战士 阿提米特」
function c31339260.initial_effect(c)
	c:EnableReviveLimit()
	-- 为不死战士添加融合召唤手续，融合素材为卡号32274490的「白骨」与卡号55550921的「格斗战士 阿提米特」，后两个true表示允许使用融合素材代用品/替代素材。
	aux.AddFusionProcCode2(c,32274490,55550921,true,true)
end
