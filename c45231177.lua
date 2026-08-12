--炎の剣士
-- 效果：
-- 「火焰操纵者」＋「传说的剑豪 正树」
function c45231177.initial_effect(c)
	c:EnableReviveLimit()
	-- 融合召唤手续：使用卡号为34460851和44287299的2只怪兽为融合素材
	aux.AddFusionProcCode2(c,34460851,44287299,true,true)
end
