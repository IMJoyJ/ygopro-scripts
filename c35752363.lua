--朱雀
-- 效果：
-- 「赤剑之莱蒙多斯」＋「炎之魔神」
function c35752363.initial_effect(c)
	c:EnableReviveLimit()
	-- 融合召唤手续：使用卡号为62403074和71407486的2只怪兽为融合素材
	aux.AddFusionProcCode2(c,62403074,71407486,true,true)
end
