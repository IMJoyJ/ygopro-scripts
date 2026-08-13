--魔導雑貨商人
-- 效果：
-- ①：这张卡反转的场合发动。直到魔法·陷阱卡出现为止从自己卡组上面翻卡，那张魔法·陷阱卡加入手卡。剩下的翻开的卡全部送去墓地。
function c32362575.initial_effect(c)
	-- ①：这张卡反转的场合发动。直到魔法·陷阱卡出现为止从自己卡组上面翻卡，那张魔法·陷阱卡加入手卡。剩下的翻开的卡全部送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(c32362575.operation)
	c:RegisterEffect(e1)
end
-- 执行反转效果时的处理：从自己卡组中找到最靠近卡组顶端的魔法·陷阱卡；若卡组中没有魔法·陷阱卡，则只向自己确认全部卡组后洗切并结束；否则从卡组顶翻开到那张卡为止，将那张魔法·陷阱卡加入手卡，其余翻开的卡送去墓地；若那张卡不能加入手卡，则将全部翻开的卡送去墓地。
function c32362575.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有魔法·陷阱卡组成的集合，用于确定最上方（最靠近卡组顶端）的那张魔法·陷阱卡。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_DECK,0,nil,TYPE_SPELL+TYPE_TRAP)
	-- 获取自己卡组当前的卡片总数。
	local dcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if dcount==0 then return end
	if g:GetCount()==0 then
		-- 卡组中没有魔法·陷阱卡时，向自己确认卡组最上方的全部卡片，即把整个卡组翻开确认。
		Duel.ConfirmDecktop(tp,dcount)
		-- 由于本次只是确认而并未实际取出或移动卡片，确认后洗切卡组以复原卡组顺序。
		Duel.ShuffleDeck(tp)
		return
	end
	local seq=-1
	local tc=g:GetFirst()
	local spcard=nil
	while tc do
		if tc:GetSequence()>seq then
			seq=tc:GetSequence()
			spcard=tc
		end
		tc=g:GetNext()
	end
	-- 向自己确认从卡组顶端到最上方那张魔法·陷阱卡为止的卡片，也就是本次效果将要翻开的卡片。
	Duel.ConfirmDecktop(tp,dcount-seq)
	if spcard:IsAbleToHand() then
		-- 禁用下一次操作后自动洗切卡组的检测，保证先取出魔法·陷阱卡后仍能按原卡组顺序将其上方的卡送去墓地。
		Duel.DisableShuffleCheck()
		-- 将那张最上方的魔法·陷阱卡加入其持有者的手卡（nil 表示送回持有者手卡）；若无法加入手卡则不会执行此步。
		Duel.SendtoHand(spcard,nil,REASON_EFFECT)
		-- 将已翻开且位于那张魔法·陷阱卡上方的剩余卡片从卡组送去墓地，送墓原因标记为效果和翻开（森罗）。
		Duel.DiscardDeck(tp,dcount-seq-1,REASON_EFFECT+REASON_REVEAL)
		-- 向对方玩家展示那张被加入手卡的魔法·陷阱卡，使对方也能确认加入手卡的是哪张卡。
		Duel.ConfirmCards(1-tp,spcard)
		-- 洗切该玩家手卡，将刚加入的魔法·陷阱卡混入整手牌中，避免对手根据手卡顺序得知其位置。
		Duel.ShuffleHand(tp)
	-- 若那张魔法·陷阱卡不能加入手卡，则不将其加入手卡，而是将本次翻开的所有卡片（包括该魔法·陷阱卡）直接送去墓地。
	else Duel.DiscardDeck(tp,dcount-seq,REASON_EFFECT+REASON_REVEAL) end
end
