--スペシャルハリケーン
-- 效果：
-- 丢弃1张手卡。破坏场上存在的所有特殊召唤的怪兽。
function c42598242.initial_effect(c)
	-- 丢弃1张手卡。破坏场上存在的所有特殊召唤的怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c42598242.cost)
	e1:SetTarget(c42598242.target)
	e1:SetOperation(c42598242.activate)
	c:RegisterEffect(e1)
end
-- 发动代价处理函数：先检查手牌中是否存在可丢弃的卡，然后实际丢弃1张手卡作为发动代价。
function c42598242.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段：确认手牌中存在至少1张除本卡以外可以丢弃的手卡，以满足丢弃1张手卡的代价条件。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际执行代价：从手牌选择并丢弃1张卡送去墓地，丢弃原因标记为COST+DISCARD。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 筛选条件：怪兽的召唤类型为特殊召唤（即该怪兽是特殊召唤的怪兽）。
function c42598242.filter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 发动目标条件与操作信息设定：确认场上有特殊召唤的怪兽，并将场上所有特殊召唤的怪兽登记为将被破坏的对象。
function c42598242.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：确认场上存在至少1只特殊召唤的怪兽，满足发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c42598242.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有特殊召唤的怪兽组成集合（不取对象，效果处理时适用）。
	local g=Duel.GetMatchingGroup(c42598242.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将破坏分类及预计破坏数量写入操作信息，供连锁中相关效果的发动检测与判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理函数：在效果处理时获取场上全部特殊召唤的怪兽，并将其全部破坏。
function c42598242.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取场上所有特殊召唤的怪兽，以当前场上实际存在为准。
	local g=Duel.GetMatchingGroup(c42598242.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 以效果原因将获取到的特殊召唤怪兽全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
