--ナチュル・ガオドレイク
-- 效果：
-- 地属性调整＋调整以外的地属性怪兽1只以上
function c16527176.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求1只满足条件的调整怪兽和1只满足条件的调整以外的怪兽
	aux.AddSynchroProcedure(c,c16527176.synfilter,aux.NonTuner(c16527176.synfilter),1)
	c:EnableReviveLimit()
end
-- 过滤满足地属性条件的怪兽
function c16527176.synfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH)
end
