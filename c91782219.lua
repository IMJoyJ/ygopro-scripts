--クラブ・タートル
-- 效果：
-- 「龟的誓言」降临。必须从场地和手卡把等级直到8以上的卡作为祭品。
function c91782219.initial_effect(c)
	-- 将「龟的誓言」注册为本卡片记载的卡名
	aux.AddCodeList(c,76806714)
	c:EnableReviveLimit()
end
