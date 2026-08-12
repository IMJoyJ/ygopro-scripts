--ライオンの儀式
-- 效果：
-- 「超级战狮」的降临必需。必须从手卡·自己场上把等级合计直到7以上的怪兽解放。
function c54539105.initial_effect(c)
	-- 为当前卡片添加仪式召唤「超级战狮」的效果，要求解放手卡或自己场上等级合计在7以上的怪兽
	aux.AddRitualProcGreaterCode(c,33951077)
end
