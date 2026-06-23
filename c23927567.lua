--幸運を告げるフクロウ
-- 效果：
-- 反转：从卡组中选择1张场地魔法卡，放在自己卡组最上面。当「王家长眠之谷」在场上存在时，可以将选择的场地魔法卡加入手卡。
function c23927567.initial_effect(c)
	-- 反转效果初始化，设置效果类别为检索和回手，类型为反转效果，关联处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(c23927567.operation)
	c:RegisterEffect(e1)
end
-- 反转效果的处理函数
function c23927567.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择一张场地魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(23927567,1))  --"请选择一张场地魔法卡"
	-- 从卡组中选择一张场地魔法卡
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_DECK,0,1,1,nil,TYPE_FIELD)
	local tc=g:GetFirst()
	if tc then
		-- 判断王家长眠之谷在场且选择的卡能加入手卡，若满足条件则选择是否将卡加入手卡
		if Duel.IsEnvironment(47355498) and tc:IsAbleToHand() and Duel.SelectOption(tp,1190,aux.Stringid(23927567,0))==0 then  --"在卡组最上面放置"
			-- 将选择的场地魔法卡加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方确认该卡加入手卡
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 洗切玩家卡组
			Duel.ShuffleDeck(tp)
			-- 将卡移至玩家卡组最上方
			Duel.MoveSequence(tc,SEQ_DECKTOP)
			-- 确认玩家卡组最上方的1张卡
			Duel.ConfirmDecktop(tp,1)
		end
	end
end
