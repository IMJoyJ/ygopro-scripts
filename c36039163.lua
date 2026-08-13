--ペンギン・ナイト
-- 效果：
-- 这张卡被对方的效果从卡组送去墓地时，把自己墓地存在的全部卡回到卡组。
function c36039163.initial_effect(c)
	-- “这张卡被对方的效果从卡组送去墓地时，把自己墓地存在的全部卡回到卡组。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36039163,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c36039163.tdcon)
	e1:SetTarget(c36039163.tdtg)
	e1:SetOperation(c36039163.tdop)
	c:RegisterEffect(e1)
end
-- 判定触发条件：这张卡被送去墓地前位于卡组，且该次送去墓地是由对方发动的效果（非战斗、非代价）造成的。
function c36039163.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK) and bit.band(r,REASON_EFFECT)~=0 and rp==1-tp
end
-- 效果发动时的目标处理：若为发动检查则允许发动；取出自己墓地的全部卡，并将这些卡在连锁信息中登记为本次效果将要送回卡组的对象。
function c36039163.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己（当前效果持有者控制方）墓地中的全部卡，作为后续回卡组操作的对象。
	local g=Duel.GetFieldGroup(tp,LOCATION_GRAVE,0)
	-- 设置操作信息：将这些墓地中的卡作为本次效果送回卡组的对象，数量为其总数，使相关卡（如星尘龙）能正确响应。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理时的操作：取自己墓地的全部卡，若未因王家长眠之谷等效果被无效，则将它们全部送回持有者卡组并洗切卡组。
function c36039163.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地中的全部卡（效果处理时重新获取，以反映当前实际状态）。
	local g=Duel.GetFieldGroup(tp,LOCATION_GRAVE,0)
	-- 若这些墓地卡受到王家长眠之谷等效果的影响，则立即中止本次处理（效果被无效）。
	if aux.NecroValleyNegateCheck(g) then return end
	-- 将墓地中的全部卡送回持有者的卡组（以回卡组并洗牌的方式，原因记为效果），并检查是否实际有卡被送回。
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		-- 如果刚才处理过的卡中确实有卡位于卡组，则洗切自己的卡组，完成卡组的重新排列。
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	end
end
