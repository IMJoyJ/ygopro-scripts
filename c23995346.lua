--青眼の究極竜
-- 效果：
-- 「青眼白龙」＋「青眼白龙」＋「青眼白龙」
function c23995346.initial_effect(c)
	c:EnableReviveLimit()
	-- 为此卡添加融合召唤手续：指定以3只卡号89631139的“青眼白龙”作为融合素材（重复素材），并启用融合素材代用等替代融合素材规则（true,true参数）。
	aux.AddFusionProcCodeRep(c,89631139,3,true,true)
end
