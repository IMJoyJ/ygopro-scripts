--覚醒の勇士 ガガギゴ
-- 效果：
-- 4星怪兽×3
function c9053187.initial_effect(c)
	-- 添加超量召唤手续，需要3只4星怪兽作为超量素材
	aux.AddXyzProcedure(c,nil,4,3)
	c:EnableReviveLimit()
end
