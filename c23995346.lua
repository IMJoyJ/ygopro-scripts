--青眼の究極竜
-- 效果：
-- 「青眼白龙」＋「青眼白龙」＋「青眼白龙」
function c23995346.initial_effect(c)
	c:EnableReviveLimit()
	-- 将该卡设为需要3个编号为89631139的怪兽作为融合素材的融合召唤，且该融合召唤视为满足融合条件的融合召唤
	aux.AddFusionProcCodeRep(c,89631139,3,true,true)
end
