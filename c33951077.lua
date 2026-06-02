--スーパー・ウォー・ライオン
-- 效果：
-- 「狮子的仪式」降临。
function c33951077.initial_effect(c)
	-- 注册卡片密码54539105（狮子的仪式）至当前卡片的记载卡密码列表中。
	aux.AddCodeList(c,54539105)
	c:EnableReviveLimit()
end
