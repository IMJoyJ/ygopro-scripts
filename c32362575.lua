--魔導雑貨商人
-- 效果：
-- ①：这张卡反转的场合发动。直到魔法·陷阱卡出现为止从自己卡组上面翻卡，那张魔法·陷阱卡加入手卡。剩下的翻开的卡全部送去墓地。
function c32362575.initial_effect(c)
	-- ①：这张卡反转的场合发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(c32362575.operation)
	c:RegisterEffect(e1)
end
-- 直到魔法·陷阱卡出现为止从自己卡组上面翻卡，那张魔法·陷阱卡加入手卡。剩下的翻开的卡全部送去墓地。
function c32362575.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足条件的魔法·陷阱卡组
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_DECK,0,nil,TYPE_SPELL+TYPE_TRAP)
	-- 获取自己卡组的卡数量
	local dcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if dcount==0 then return end
	if g:GetCount()==0 then
		-- 确认玩家卡组最上方的卡数量
		Duel.ConfirmDecktop(tp,dcount)
		-- 手动洗切玩家卡组
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
	-- 确认玩家卡组最上方到指定位置的卡
	Duel.ConfirmDecktop(tp,dcount-seq)
	if spcard:IsAbleToHand() then
		-- 使下一个操作不检查是否需要洗切卡组或手卡
		Duel.DisableShuffleCheck()
		-- 将目标卡加入手卡
		Duel.SendtoHand(spcard,nil,REASON_EFFECT)
		-- 将指定数量的卡从卡组最上端送去墓地
		Duel.DiscardDeck(tp,dcount-seq-1,REASON_EFFECT+REASON_REVEAL)
		-- 给玩家确认目标卡
		Duel.ConfirmCards(1-tp,spcard)
		-- 手动洗切玩家手卡
		Duel.ShuffleHand(tp)
	-- 将剩余翻开的卡全部送去墓地
	else Duel.DiscardDeck(tp,dcount-seq,REASON_EFFECT+REASON_REVEAL) end
end
