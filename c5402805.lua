--天威の鬼神
-- 效果：
-- 包含连接怪兽的怪兽2只以上
function c5402805.initial_effect(c)
	-- 为卡片添加连接召唤手续，需要2到3张怪兽作为素材，且素材需满足lcheck过滤条件
	aux.AddLinkProcedure(c,nil,2,3,c5402805.lcheck)
	c:EnableReviveLimit()
end
-- 过滤函数，检查用于连接召唤的素材组中是否存在至少1只连接怪兽
function c5402805.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_LINK)
end
