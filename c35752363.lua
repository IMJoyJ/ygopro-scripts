--朱雀
-- 效果：
-- 「赤剑之莱蒙多斯」＋「炎之魔神」
function c35752363.initial_effect(c)
	c:EnableReviveLimit()
	-- 为「朱雀」添加融合召唤手续，指定融合素材为「赤剑之莱蒙多斯」（62403074）和「炎之魔神」（71407486），并允许使用融合素材代用品等替代素材。
	aux.AddFusionProcCode2(c,62403074,71407486,true,true)
end
