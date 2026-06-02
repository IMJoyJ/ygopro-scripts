--スカルライダー
-- 效果：
-- 使用「骷髅骑手的复活」特殊召唤。
function c99721536.initial_effect(c)
	-- 将仪式魔法卡「骷髅骑手的复活」的卡号注册到这张卡关联的卡片列表中
	aux.AddCodeList(c,31066283)
	c:EnableReviveLimit()
end
