--聖女ジャンヌ
-- 效果：
-- 「大慈大悲的修女」＋「堕天使 玛丽」
function c21175632.initial_effect(c)
	c:EnableReviveLimit()
	-- 为「圣女 贞德」添加融合召唤手续，使其可以以卡号84080938的「大慈大悲的修女」与卡号57579381的「堕天使 玛丽」为融合素材进行融合召唤；两个true参数表示启用融合素材代用等替代判定规则。
	aux.AddFusionProcCode2(c,84080938,57579381,true,true)
end
