--要塞クジラの誓い
-- 效果：
-- 「要塞鲸」的降临必要。必须从场上或者手札，牺牲奉献等级合计为7个以上的卡。
function c77454922.initial_effect(c)
	-- 为当前卡片添加仪式召唤「要塞鲸」的效果，素材等级合计可以超过原本等级（7星以上）
	aux.AddRitualProcGreaterCode(c,62337487)
end
