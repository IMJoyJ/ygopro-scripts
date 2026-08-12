--悪魔鏡の儀式
-- 效果：
-- 「恶魔镜」降临必要。场上和手卡加起来总共6颗星以上的怪兽作祭品。
function c81933259.initial_effect(c)
	-- 为本卡添加仪式召唤「恶魔镜」的效果，解放的怪兽等级合计需要等于或超过该怪兽的等级
	aux.AddRitualProcGreaterCode(c,31890399)
end
