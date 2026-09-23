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
-- 发动Cost：丢弃1张手卡
function c71344451.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手牌丢弃1张卡作为Cost
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 发动条件判断及操作信息设置
function c71344451.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的卡片数量
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	-- 检查对方场上卡片数量是否大于0、卡组剩余卡片是否足够送去墓地且可以从卡组送去墓地
	if chk==0 then return ct>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>ct and Duel.IsPlayerCanDiscardDeck(tp,ct)
		-- 检查自己是否可以抽卡
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 设置操作信息：从卡组将卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,ct)
	-- 设置操作信息：自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	-- 设置操作信息：从墓地将卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理：把对方场上卡片数量的卡从卡组送去墓地并抽1张卡确认，根据抽到的卡适用破坏伤害或墓地回收效果
function c71344451.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的卡片数量
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	-- 将对方场上卡片数量的卡从卡组顶端送去墓地
	if ct>0 and Duel.DiscardDeck(tp,ct,REASON_EFFECT)~=0 then
		-- 计算实际送去墓地的卡片数量
		local ct2=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE):GetCount()
		if ct2==0 then return end
		-- 中断效果处理（分割前后时点）
		Duel.BreakEffect()
		-- 自己抽1张卡
		if Duel.Draw(tp,1,REASON_EFFECT)~=0 then
			-- 获取抽到的卡
			local tc=Duel.GetOperatedGroup():GetFirst()
			-- 向双方展示确认抽到的卡
			Duel.ConfirmCards(1-tp,tc)
			if tc:IsCode(71344451) then
				-- 抽到的卡送去墓地
				if Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
					-- 获取场上除了此卡以外的所有卡
					local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
					-- 破坏场上的卡
					Duel.Destroy(sg,REASON_EFFECT)
					-- 获取破坏并成功送去墓地的卡片组
					local tg=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE)
					if tg:GetCount()>0 then
						local dam=tg:GetCount()*2000
						if dam>0 then
							-- 中断效果处理（分割前后时点）
							Duel.BreakEffect()
							-- 给与对方破坏送墓卡片数量×2000的伤害
							Duel.Damage(1-tp,dam,REASON_EFFECT)
						end
					end
				end
				-- 洗切手牌
				Duel.ShuffleHand(tp)
			else
				-- 洗切手牌
				Duel.ShuffleHand(tp)
				-- 提示选择要返回卡组的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
				-- 选择送去墓地数量的自己墓地的卡
				local dg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToDeck),tp,LOCATION_GRAVE,0,ct2,ct2,nil)
				if dg:GetCount()>0 then
					-- 中断效果处理（分割前后时点）
					Duel.BreakEffect()
					-- 显示选中的卡片被选为对象
					Duel.HintSelection(dg)
					-- 将选中的卡送回卡组并洗切卡组
					Duel.SendtoDeck(dg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
				end
			end
		end
	end
end
