--水晶の占い師
-- 效果：
-- 反转：从自己卡组上面翻开2张卡，选择那之内的1张加入手卡。剩下的回到卡组最下面。
function c82099401.initial_effect(c)
	-- 反转：从自己卡组上面翻开2张卡，选择那之内的1张加入手卡。剩下的回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82099401,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(c82099401.operation)
	c:RegisterEffect(e1)
end
-- 反转效果的处理：翻开卡组顶端2张卡，将其中1张加入手牌，剩下的1张放回卡组最下方。
function c82099401.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己卡组的卡片数量不足2张，则不处理效果。
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<2 then return end
	-- 确认（翻开）自己卡组最上方的2张卡。
	Duel.ConfirmDecktop(tp,2)
	-- 获取自己卡组最上方的2张卡片组。
	local g=Duel.GetDecktopGroup(tp,2)
	if g:GetCount()>0 then
		-- 关闭洗牌检测，防止后续操作触发系统自动洗牌。
		Duel.DisableShuffleCheck()
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local add=g:Select(tp,1,1,nil)
		if add:GetFirst():IsAbleToHand() then
			-- 将选择的卡因效果加入玩家手牌。
			Duel.SendtoHand(add,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手牌的卡片。
			Duel.ConfirmCards(1-tp,add)
			-- 洗切玩家的手牌。
			Duel.ShuffleHand(tp)
		else
			-- 若无法加入手牌，则将该卡送去墓地。
			Duel.SendtoGrave(add,REASON_EFFECT)
		end
		-- 中断效果，使后续的放回卡组底端操作不与加入手牌视为同时处理。
		Duel.BreakEffect()
		-- 获取当前卡组最上方剩下的1张卡。
		local back=Duel.GetDecktopGroup(tp,1)
		-- 将剩下的那张卡移动到卡组最下面。
		Duel.MoveSequence(back:GetFirst(),SEQ_DECKBOTTOM)
	end
end
