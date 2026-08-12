--トゥーンのかばん
-- 效果：
-- ①：自己场上有卡通怪兽存在，对方把怪兽召唤·反转召唤·特殊召唤时才能发动。那些怪兽回到持有者卡组。
function c5832914.initial_effect(c)
	-- ①：自己场上有卡通怪兽存在，对方把怪兽召唤·反转召唤·特殊召唤时才能发动。那些怪兽回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c5832914.condition)
	e1:SetTarget(c5832914.target)
	e1:SetOperation(c5832914.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的卡通怪兽
function c5832914.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 发动条件：检查自己场上是否存在卡通怪兽
function c5832914.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的卡通怪兽
	return Duel.IsExistingMatchingCard(c5832914.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：由对方召唤·反转召唤·特殊召唤且可以回到卡组的怪兽
function c5832914.filter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsAbleToDeck()
end
-- 效果的目标选择与操作信息注册：确认对方召唤·反转召唤·特殊召唤的怪兽并将其设为效果处理对象
function c5832914.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c5832914.filter,1,nil,1-tp) end
	local g=eg:Filter(c5832914.filter,nil,1-tp)
	-- 将本次召唤·反转召唤·特殊召唤的对方怪兽设为效果处理的对象
	Duel.SetTargetCard(g)
	-- 设置效果处理信息：将这些怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理：将作为对象的怪兽送回持有者卡组并洗牌
function c5832914.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与此效果相关的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将目标怪兽送回持有者卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
