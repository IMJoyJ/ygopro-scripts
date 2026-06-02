--デビルズ・ミラー
-- 效果：
-- 「恶魔镜的仪式」降临。
function c31890399.initial_effect(c)
	-- 将「恶魔镜的仪式」的卡片密码加入当前卡片的关联卡片列表中
	aux.AddCodeList(c,81933259)
	c:EnableReviveLimit()
end
