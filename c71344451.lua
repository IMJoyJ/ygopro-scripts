--一撃必殺！居合いドロー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：丢弃1张手卡才能发动。把对方场上的卡数量的卡从自己卡组上面送去墓地。那之后，自己抽1张，给双方确认。那是「一击必杀！居合抽卡」的场合，再把那张送去墓地，场上的卡全部破坏。那之后，给与对方这个效果破坏送去墓地的卡数量×2000伤害。不是的场合，再让自己让这个效果从卡组送去墓地的卡数量的自己墓地的卡回到卡组。
function c71344451.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：丢弃1张手卡才能发动。把对方场上的卡数量的卡从自己卡组上面送去墓地。那之后，自己抽1张，给双方确认。那是「一击必杀！居合抽卡」的场合，再把那张送去墓地，场上的卡全部破坏。那之后，给与对方这个效果破坏送去墓地的卡数量×2000伤害。不是的场合，再让自己让这个效果从卡组送去墓地的卡数量的自己墓地的卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DRAW+CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,71344451+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c71344451.cost)
	e1:SetTarget(c71344451.target)
	e1:SetOperation(c71344451.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的Cost：丢弃1张手卡。
function c71344451.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在除这张卡以外的可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家选择并丢弃1张手卡作为发动Cost。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果发动的Target：检查对方场上是否有卡、自己卡组数量是否足够、是否能将卡组顶端的卡送去墓地以及是否能抽卡。
function c71344451.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的卡片数量。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	-- 检查对方场上是否有卡，且自己卡组数量大于对方场上卡片数量，且自己可以把卡组顶端的卡送去墓地。
	if chk==0 then return ct>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>ct and Duel.IsPlayerCanDiscardDeck(tp,ct)
		-- 检查自己是否可以抽1张卡。
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果处理信息：从卡组送去墓地的卡片数量为对方场上的卡片数量。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,ct)
	-- 设置效果处理信息：自己抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	-- 设置效果处理信息：预计有墓地的卡回到卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理：将卡组顶端的卡送去墓地并抽卡，根据抽到的卡是否为「一击必杀！居合抽卡」来决定是破坏场上的卡并给予伤害，还是将墓地的卡回到卡组。
function c71344451.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方场上的卡片数量。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	-- 如果对方场上有卡，则将对应数量的卡从自己卡组上面送去墓地。
	if ct>0 and Duel.DiscardDeck(tp,ct,REASON_EFFECT)~=0 then
		-- 获取实际因该效果从卡组送去墓地的卡片数量。
		local ct2=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE):GetCount()
		if ct2==0 then return end
		-- 中断当前效果，使后续的抽卡处理与送去墓地不视为同时处理。
		Duel.BreakEffect()
		-- 自己抽1张卡。
		if Duel.Draw(tp,1,REASON_EFFECT)~=0 then
			-- 获取刚刚抽到的那张卡。
			local tc=Duel.GetOperatedGroup():GetFirst()
			-- 将抽到的卡给双方确认。
			Duel.ConfirmCards(1-tp,tc)
			-- 重新洗切手卡。
			Duel.ShuffleHand(tp)
			if tc:IsCode(71344451) then
				-- 如果抽到的是「一击必杀！居合抽卡」，则将那张卡送去墓地。
				if Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
					-- 获取场上除这张卡以外的所有卡片。
					local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
					-- 破坏场上的全部卡片。
					Duel.Destroy(sg,REASON_EFFECT)
					-- 筛选出因该效果被破坏并送去墓地的卡片。
					local tg=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE)
					if tg:GetCount()>0 then
						local dam=tg:GetCount()*2000
						if dam>0 then
							-- 中断当前效果，使后续的伤害处理与破坏不视为同时处理。
							Duel.BreakEffect()
							-- 给与对方被破坏送去墓地的卡数量×2000的伤害。
							Duel.Damage(1-tp,dam,REASON_EFFECT)
						end
					end
				end
			else
				-- 提示玩家选择要回到卡组的卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
				-- 让玩家从自己墓地选择与送去墓地数量相同的、可以回到卡组的卡（受王家长眠之谷影响）。
				local dg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToDeck),tp,LOCATION_GRAVE,0,ct2,ct2,nil)
				if dg:GetCount()>0 then
					-- 确认并显示玩家选择的卡片。
					Duel.HintSelection(dg)
					-- 将选择的卡片送回卡组并洗卡。
					Duel.SendtoDeck(dg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
				end
			end
		end
	end
end
