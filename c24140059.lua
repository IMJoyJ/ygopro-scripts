--不幸を告げる黒猫
-- 效果：
-- ①：这张卡反转的场合发动。从卡组选1张陷阱卡在卡组最上面放置。「王家长眠之谷」在场上存在的场合，那张陷阱卡可以作为在卡组最上面放置的代替而加入手卡。
function c24140059.initial_effect(c)
	-- ①：这张卡反转的场合发动。从卡组选1张陷阱卡在卡组最上面放置。「王家长眠之谷」在场上存在的场合，那张陷阱卡可以作为在卡组最上面放置的代替而加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(c24140059.operation)
	c:RegisterEffect(e1)
end
-- 反转效果的处理：从自己卡组选择1张陷阱卡；若场上有「王家长眠之谷」且该卡可以加入手卡，则由玩家选择是否改为加入手卡（选择则加入手卡并向对手确认，否则或不满足条件时洗牌后将陷阱卡放置在卡组顶并确认卡组顶）。
function c24140059.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家发出选择提示，将“请选择一张陷阱卡”的提示信息写入缓存，供随后Duel.SelectMatchingCard选择时显示。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(24140059,1))  --"请选择一张陷阱卡"
	-- 从自己卡组中筛选并选择1张陷阱卡作为本次效果的处理对象（仅进行选择，不会移动卡牌位置）。
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_DECK,0,1,1,nil,TYPE_TRAP)
	local tc=g:GetFirst()
	if tc then
		-- 判断是否满足“王家长眠之谷”在场且所选的陷阱卡能够加入手卡；若满足，再让玩家选择是否以“加入手卡”代替“放置到卡组顶”（选择对应选项时返回0则执行加入手卡分支）。
		if Duel.IsEnvironment(47355498) and tc:IsAbleToHand() and Duel.SelectOption(tp,1190,aux.Stringid(24140059,0))==0 then  --"在卡组最上面放置"
			-- 将选中的陷阱卡以效果原因加入其持有者的手卡，即发动效果的玩家检索并入手。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 将那张加入手卡的陷阱卡展示给对手确认，以公开检索/加入手卡的结果。
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 洗切玩家的卡组，使检索后剩余的卡重新随机排列，再进行后续放置卡组顶的处理。
			Duel.ShuffleDeck(tp)
			-- 将选中的陷阱卡移动到卡组最上方，也就是把该陷阱卡放置在卡组顶端。
			Duel.MoveSequence(tc,SEQ_DECKTOP)
			-- 确认玩家卡组最上方1张卡，以向双方展示并确认该陷阱卡已经被放置到卡组顶。
			Duel.ConfirmDecktop(tp,1)
		end
	end
end
