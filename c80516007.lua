--レア・フィッシュ
-- 效果：
-- 「融合体」＋「恍惚的人鱼」
function c80516007.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，以「融合体」和「恍惚的人鱼」为融合素材，允许使用融合代替素材
	aux.AddFusionProcCode2(c,1641882,75376965,true,true)
end
