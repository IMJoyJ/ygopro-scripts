--炎の剣士
-- 效果：
-- 「火焰操纵者」＋「传说的剑豪 正树」
function c45231177.initial_effect(c)
	c:EnableReviveLimit()
	-- 为「炎之剑士」添加融合召唤手续：指定以「火焰操纵者」（34460851）和「传说的剑豪 正树」（44287299）各1只为融合素材进行融合召唤，并允许使用融合素材代用品等规则。
	aux.AddFusionProcCode2(c,34460851,44287299,true,true)
end
