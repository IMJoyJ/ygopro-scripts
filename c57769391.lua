--オルターガイスト・ピクシール
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把这张卡解放才能发动。从自己卡组上面把3张卡翻开，从那之中选1张「幻变骚灵」卡加入手卡，剩下的卡送去墓地。
function c57769391.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：把这张卡解放才能发动。从自己卡组上面把3张卡翻开，从那之中选1张「幻变骚灵」卡加入手卡，剩下的卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57769391,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,57769391)
	e1:SetCost(c57769391.cost)
	e1:SetTarget(c57769391.target)
	e1:SetOperation(c57769391.operation)
	c:RegisterEffect(e1)
end
-- 定义发动代价（Cost）：检查自身是否可以解放，并解放自身。
function c57769391.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义发动条件与对象选择（Target）：检查是否能将卡组顶端3张卡送去墓地，且其中存在可以加入手牌的卡。
function c57769391.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查玩家是否能将卡组顶端的3张卡送去墓地。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3)
		-- 并且卡组顶端的3张卡中至少有1张是可以加入手牌的卡。
		and Duel.GetDecktopGroup(tp,3):FilterCount(Card.IsAbleToHand,nil)>0 end
end
-- 过滤条件：可以加入手牌的「幻变骚灵」卡。
function c57769391.filter(c)
	return c:IsAbleToHand() and c:IsSetCard(0x103)
end
-- 定义效果处理（Operation）：翻开卡组顶端3张卡，将其中的1张「幻变骚灵」卡加入手牌，其余卡送去墓地。
function c57769391.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若不能将卡组顶端3张卡送去墓地则不处理。
	if not Duel.IsPlayerCanDiscardDeck(tp,3) then return end
	-- 确认（翻开）自己卡组顶端的3张卡。
	Duel.ConfirmDecktop(tp,3)
	-- 获取自己卡组顶端的3张卡组。
	local g=Duel.GetDecktopGroup(tp,3)
	if g:GetCount()>0 then
		-- 禁用接下来的自动洗卡检测。
		Duel.DisableShuffleCheck()
		if g:IsExists(c57769391.filter,1,nil) then
			-- 提示玩家选择要加入手牌的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:FilterSelect(tp,c57769391.filter,1,1,nil)
			-- 将选中的卡加入手牌。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手牌的卡。
			Duel.ConfirmCards(1-tp,sg)
			-- 洗切玩家的手牌。
			Duel.ShuffleHand(tp)
			g:Sub(sg)
		end
		-- 将剩下的卡作为因翻开而送去墓地处理送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
	end
end
