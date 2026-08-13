--魔力浄化
-- 效果：
-- 丢弃1张手卡。场上表侧表示存在的永续魔法全部破坏。
function c1669772.initial_effect(c)
	-- 丢弃1张手卡。场上表侧表示存在的永续魔法全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c1669772.cost)
	e1:SetTarget(c1669772.target)
	e1:SetOperation(c1669772.activate)
	c:RegisterEffect(e1)
end
-- 定义代价函数：以丢弃1张手卡作为发动代价，负责检查并执行丢弃。
function c1669772.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查代价条件：手牌中是否存在除自身以外至少1张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 支付代价：从手牌中选择1张可以丢弃的卡丢弃（原因：COST+DISCARD）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义筛选函数：选取场上表侧表示且类型为永续魔法的卡。
function c1669772.filter(c)
	return c:IsFaceup() and c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS
end
-- 定义发动目标判定：确认场上有表侧表示永续魔法，并记录将被破坏的全部此类卡片。
function c1669772.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测场上（双方魔陷区）是否存在至少1张表侧表示永续魔法，以判定效果是否满足发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c1669772.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
	-- 获取当前场上所有表侧表示永续魔法的集合。
	local g=Duel.GetMatchingGroup(c1669772.filter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	-- 将上述卡片集合登记为本次效果将破坏的对象，并记录破坏数量，供连锁确认。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：重新取得当前所有表侧表示永续魔法并将其全部破坏。
function c1669772.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时重新获取场上所有表侧表示永续魔法（因处理前场上可能变化）。
	local g=Duel.GetMatchingGroup(c1669772.filter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	-- 以效果原因（REASON_EFFECT）破坏这些永续魔法卡。
	Duel.Destroy(g,REASON_EFFECT)
end
