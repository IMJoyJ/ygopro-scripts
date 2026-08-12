--先史遺産アステカ・マスク・ゴーレム
-- 效果：
-- 自己回合自己是有把名字带有「先史遗产」的魔法卡发动的场合，这张卡可以从手卡特殊召唤。「先史遗产 阿兹特克面具石人」在自己场上只能有1只表侧表示存在。
function c94766498.initial_effect(c)
	c:SetUniqueOnField(1,0,94766498)
	-- 自己回合自己是有把名字带有「先史遗产」的魔法卡发动的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c94766498.hspcon)
	c:RegisterEffect(e1)
	-- 添加一个自定义活动计数器，用于监控玩家在连锁中发动卡片或效果的操作
	Duel.AddCustomActivityCounter(94766498,ACTIVITY_CHAIN,c94766498.chainfilter)
end
-- 过滤函数，当玩家发动「先史遗产」魔法卡时返回false，使自定义活动计数器增加
function c94766498.chainfilter(re,tp,cid)
	return not (re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsSetCard(0x70))
end
-- 特殊召唤规则的条件函数，用于判断是否满足特殊召唤的条件
function c94766498.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查本回合该玩家发动「先史遗产」魔法卡的次数是否大于0，且自己场上是否有可用的怪兽区域
	return Duel.GetCustomActivityCount(94766498,tp,ACTIVITY_CHAIN)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
