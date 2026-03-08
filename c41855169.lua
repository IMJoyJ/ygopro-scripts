--昇霊術師 ジョウゲン
-- 效果：
-- 把手卡随机1张丢弃去墓地才能发动。场上的特殊召唤的怪兽全部破坏。此外，只要这张卡在场上表侧表示存在，双方不能把怪兽特殊召唤。
function c41855169.initial_effect(c)
	-- 效果原文：双方不能把怪兽特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	c:RegisterEffect(e1)
	-- 效果原文：场上的特殊召唤的怪兽全部破坏
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41855169,0))  --"特殊召唤的怪兽全部破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c41855169.cost)
	e2:SetTarget(c41855169.target)
	e2:SetOperation(c41855169.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查手卡中可以丢弃且能送入墓地的卡片，并排除具有效果81674782的卡片
function c41855169.cfilter(c)
	return c:IsDiscardable() and c:IsAbleToGraveAsCost() and not c:IsHasEffect(81674782)
end
-- 效果处理：检测手卡是否存在满足条件的卡片，若存在则随机选择一张丢入墓地作为代价
function c41855169.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测条件：检查手卡中是否存在至少一张满足cfilter条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c41855169.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 获取手卡组：获取当前玩家手卡区域的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	local sg=g:RandomSelect(tp,1)
	-- 执行丢弃：将选中的卡片以丢弃和支付代价的原因送入墓地
	Duel.SendtoGrave(sg,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：检查场上怪兽是否为特殊召唤召唤上场的
function c41855169.filter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 效果目标设定：检测场上是否存在至少一张特殊召唤的怪兽，若存在则设置破坏操作信息
function c41855169.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测条件：检查场上是否存在至少一张特殊召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c41855169.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取特殊召唤怪兽组：获取当前玩家场上所有特殊召唤的怪兽
	local g=Duel.GetMatchingGroup(c41855169.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：设置本次连锁将要处理的破坏对象为所有特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：对所有特殊召唤的怪兽进行破坏
function c41855169.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取特殊召唤怪兽组：获取当前玩家场上所有特殊召唤的怪兽
	local g=Duel.GetMatchingGroup(c41855169.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 执行破坏：将所有特殊召唤的怪兽以效果原因破坏
	Duel.Destroy(g,REASON_EFFECT)
end
