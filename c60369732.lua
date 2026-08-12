--大邪神の儀式
-- 效果：
-- 「大邪神 雷瑟夫」降临必要。必须把场上·手卡合计8星以上的卡作为祭品。
function c60369732.initial_effect(c)
	-- 为卡片添加仪式召唤「大邪神 雷瑟夫」的效果，要求解放场上、手卡合计8星以上的怪兽作为祭品
	aux.AddRitualProcGreaterCode(c,62420419)
end
