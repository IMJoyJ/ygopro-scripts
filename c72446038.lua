--合成魔術
-- 效果：
-- 「合成狼人」的降临需要。必须从场上或手卡把合计6星以上的卡作为祭品。
function c72446038.initial_effect(c)
	-- 为这张卡添加仪式召唤「合成狼人」的效果，且解放素材的等级合计可以超过原本等级（6星以上）
	aux.AddRitualProcGreaterCode(c,84385264)
end
