--不幸を告げる黒猫
-- 效果：
-- ①：这张卡反转的场合发动。从卡组选1张陷阱卡在卡组最上面放置。「王家长眠之谷」在场上存在的场合，那张陷阱卡可以作为在卡组最上面放置的代替而加入手卡。
function c24140059.initial_effect(c)
	-- 效果原文内容：①：这张卡反转的场合发动。从卡组选1张陷阱卡在卡组最上面放置。「王家长眠之谷」在场上存在的场合，那张陷阱卡可以作为在卡组最上面放置的代替而加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(c24140059.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：反转时发动，选择一张陷阱卡处理
function c24140059.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：提示玩家选择一张陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(24140059,1))  --"请选择一张陷阱卡"
	-- 效果作用：从卡组中选择一张陷阱卡
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_DECK,0,1,1,nil,TYPE_TRAP)
	local tc=g:GetFirst()
	if tc then
		-- 效果作用：判断是否满足「王家长眠之谷」效果发动条件并选择处理方式
		if Duel.IsEnvironment(47355498) and tc:IsAbleToHand() and Duel.SelectOption(tp,1190,aux.Stringid(24140059,0))==0 then  --"在卡组最上面放置"
			-- 效果作用：将选中的陷阱卡加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 效果作用：向对方确认加入手卡的卡片
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 效果作用：洗切玩家卡组
			Duel.ShuffleDeck(tp)
			-- 效果作用：将卡片移至卡组最上方
			Duel.MoveSequence(tc,SEQ_DECKTOP)
			-- 效果作用：确认卡组最上方的卡片
			Duel.ConfirmDecktop(tp,1)
		end
	end
end
