--天威の拳僧
-- 效果：
-- 连接怪兽以外的「天威」怪兽1只
function c32519092.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用1只满足条件的连接素材
	aux.AddLinkProcedure(c,c32519092.matfilter,1,1)
	c:EnableReviveLimit()
end
-- 过滤函数，用于筛选名字含有「天威」且不是连接怪兽的怪兽作为连接素材
function c32519092.matfilter(c)
	return c:IsLinkSetCard(0x12c) and not c:IsLinkType(TYPE_LINK)
end
