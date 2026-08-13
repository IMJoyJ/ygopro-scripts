--最終戦争
-- 效果：
-- 丢弃5张手卡。场上的卡全部破坏。
function c18591904.initial_effect(c)
	-- 丢弃5张手卡。场上的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c18591904.cost)
	e1:SetTarget(c18591904.target)
	e1:SetOperation(c18591904.activate)
	c:RegisterEffect(e1)
end
-- 发动代价的检查与执行函数：确认手牌中除本卡外存在至少5张可丢弃的卡，并在发动时从手牌选择5张丢弃作为代价。
function c18591904.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认我方手牌中除本卡外是否存在至少5张可丢弃的卡，以判定能否支付发动代价。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,5,e:GetHandler()) end
	-- 实际支付代价：从我方手牌中选择5张可丢弃的卡，以“代价+丢弃”的理由丢弃到墓地。
	Duel.DiscardHand(tp,Card.IsDiscardable,5,5,REASON_COST+REASON_DISCARD)
end
-- 目标处理函数：检查场上是否存在可破坏的卡，若存在则获取场上除本卡外的所有卡，并登记为将被破坏的卡及数量，供效果处理时使用。
function c18591904.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检查阶段：确认双方场上除本卡外存在至少一张卡，以保证后续破坏效果有可处理的对象。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 取得除本卡以外的场上全部卡片（包括双方怪兽区域和魔法与陷阱区域），组成一个卡组g。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 设置操作信息：将卡组g中的所有卡片标记为本次效果将要破坏的对象（CATEGORY_DESTROY），并记录数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理函数：在效果结算时重新获取场上卡片（若本卡仍与效果关联则排除本卡），然后全部破坏。
function c18591904.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，获取场上所有卡片，并排除仍与效果关联的本卡（若本卡已离场则排除nil，即不排除任何卡）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 以效果破坏原因为理由，将获取到的卡组g中的卡片全部破坏并送去墓地。
	Duel.Destroy(g,REASON_EFFECT)
end
