--マリン・ビースト
-- 效果：
-- 「水之魔导师」＋「大肚海蛇」
function c29929832.initial_effect(c)
	c:EnableReviveLimit()
	-- 为海兽鱼添加融合召唤手续：以「水之魔导师」（93343894）和「大肚海蛇」（94022093）作为融合素材进行融合召唤，后两个true表示允许使用融合素材代用等相关规则处理。
	aux.AddFusionProcCode2(c,93343894,94022093,true,true)
end
