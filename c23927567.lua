--幸運を告げるフクロウ
-- 效果：
-- 反转：从卡组中选择1张场地魔法卡，放在自己卡组最上面。当「王家长眠之谷」在场上存在时，可以将选择的场地魔法卡加入手卡。
function c23927567.initial_effect(c)
	-- 反转：从卡组中选择1张场地魔法卡，放在自己卡组最上面。当「王家长眠之谷」在场上存在时，可以将选择的场地魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(c23927567.operation)
	c:RegisterEffect(e1)
end
-- 处理反转效果：提示选择场地魔法卡，从卡组选1张场地魔法卡；若场上有「王家长眠之谷」且该卡可加入手卡，并且玩家选择加入手卡，则将其加入手卡并让对方确认；否则洗切卡组后将那张卡放到卡组最上方并确认卡组顶端。
function c23927567.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 将选择提示信息「请选择一张场地魔法卡」写入缓存，用于接下来的卡片选择。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(23927567,1))  --"请选择一张场地魔法卡"
	-- 从己方卡组中选取1张场地魔法卡（不取对象，在效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_DECK,0,1,1,nil,TYPE_FIELD)
	local tc=g:GetFirst()
	if tc then
		-- 检查当前场上是否存在「王家长眠之谷」、所选场地魔法卡是否能加入手卡，并让玩家选择是否将其加入手卡（选择第一项则加入手卡，否则按放回卡组顶处理）。
		if Duel.IsEnvironment(47355498) and tc:IsAbleToHand() and Duel.SelectOption(tp,1190,aux.Stringid(23927567,0))==0 then  --"在卡组最上面放置"
			-- 将选择的场地魔法卡从卡组加入手卡，操作原因为效果。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家展示刚刚加入手卡的那张场地魔法卡。
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 洗切己方卡组，使卡组顺序随机化。
			Duel.ShuffleDeck(tp)
			-- 将选择的场地魔法卡移动到己方卡组的最上方。
			Duel.MoveSequence(tc,SEQ_DECKTOP)
			-- 确认己方卡组最上方的一张卡（向相关玩家展示）。
			Duel.ConfirmDecktop(tp,1)
		end
	end
end
