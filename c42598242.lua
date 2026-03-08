--スペシャルハリケーン
-- 效果：
-- 丢弃1张手卡。破坏场上存在的所有特殊召唤的怪兽。
function c42598242.initial_effect(c)
	-- 效果原文内容：丢弃1张手卡。破坏场上存在的所有特殊召唤的怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c42598242.cost)
	e1:SetTarget(c42598242.target)
	e1:SetOperation(c42598242.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查是否可以丢弃1张手卡作为发动代价
function c42598242.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否满足丢弃手卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 效果作用：执行丢弃1张手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果作用：定义过滤函数，用于筛选特殊召唤的怪兽
function c42598242.filter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 效果作用：设置连锁处理的目标，确定要破坏的特殊召唤怪兽
function c42598242.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断场上是否存在特殊召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c42598242.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 效果作用：获取场上所有特殊召唤的怪兽组成Group
	local g=Duel.GetMatchingGroup(c42598242.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 效果作用：设置连锁操作信息，标记将要破坏的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果作用：执行破坏场上所有特殊召唤怪兽的效果
function c42598242.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：再次获取场上所有特殊召唤的怪兽组成Group
	local g=Duel.GetMatchingGroup(c42598242.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 效果作用：将指定怪兽以效果原因进行破坏
	Duel.Destroy(g,REASON_EFFECT)
end
