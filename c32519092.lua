--天威の拳僧
-- 效果：
-- 连接怪兽以外的「天威」怪兽1只
function c32519092.initial_effect(c)
	-- 为「天威之拳僧」添加连接召唤手续，要求使用恰好1只满足c32519092.matfilter过滤条件的怪兽作为连接素材，即连接怪兽以外的「天威」怪兽1只。
	aux.AddLinkProcedure(c,c32519092.matfilter,1,1)
	c:EnableReviveLimit()
end
-- 定义连接素材的过滤函数：该怪兽作为连接素材时卡名含有「天威」字段，并且不是连接怪兽，以此实现「连接怪兽以外的『天威』怪兽」这一素材要求。
function c32519092.matfilter(c)
	return c:IsLinkSetCard(0x12c) and not c:IsLinkType(TYPE_LINK)
end
