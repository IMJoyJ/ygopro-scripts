--ナチュル・ガオドレイク
-- 效果：
-- 地属性调整＋调整以外的地属性怪兽1只以上
function c16527176.initial_effect(c)
	-- 为这张卡注册同调召唤手续：调整怪兽必须满足synfilter（即地属性），调整以外的怪兽也须满足synfilter（地属性），数量为1只以上（默认最多99只）。
	aux.AddSynchroProcedure(c,c16527176.synfilter,aux.NonTuner(c16527176.synfilter),1)
	c:EnableReviveLimit()
end
-- 定义同调素材过滤函数synfilter，用于判断一张怪兽卡是否满足地属性条件，是地属性则返回true，否则返回false。
function c16527176.synfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH)
end
