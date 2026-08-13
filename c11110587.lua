--隣の芝刈り
-- 效果：
-- ①：自己卡组的数量比对方多的场合才能发动。直到卡组数量变成和对方相同为止，从自己卡组上面把卡送去墓地。
function c11110587.initial_effect(c)
	-- ①：自己卡组的数量比对方多的场合才能发动。直到卡组数量变成和对方相同为止，从自己卡组上面把卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c11110587.condition)
	e1:SetTarget(c11110587.target)
	e1:SetOperation(c11110587.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件函数：检查自己卡组数量是否比对方多。
function c11110587.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 比较自己卡组数量与对方卡组数量，若自己更多则条件成立。
	return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
end
-- 定义效果发动的目标设定函数：计算自己与对方卡组数量差，并在发动合法时登记将差数张卡从卡组送去墓地的操作信息。
function c11110587.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算自己卡组数量减去对方卡组数量的差值，即需要从自己卡组送去墓地的卡数。
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)-Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
	-- 在发动合法性检查阶段，确认差值大于0且当前玩家能够将卡组顶端对应张数送去墓地，否则不能发动。
	if chk==0 then return ct>0 and Duel.IsPlayerCanDiscardDeck(tp,ct) end
	-- 设置操作信息，将本次效果登记为从卡组送去墓地（CATEGORY_DECKDES），并记录预计处理的数量，以便后续时点判定。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,ct)
end
-- 定义效果结算时的操作函数：效果处理时重新计算卡组数量差，若差值大于0则从自己卡组顶端将等量卡送去墓地。
function c11110587.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果结算时再次计算自己与对方卡组数量的差值，作为实际从卡组送去墓地的卡数。
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)-Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
	if ct>0 then
		-- 以效果原因从自己卡组顶端将ct张卡送去墓地。
		Duel.DiscardDeck(tp,ct,REASON_EFFECT)
	end
end
