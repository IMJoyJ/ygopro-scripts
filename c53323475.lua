--傀儡流儀－パペット・シャーク
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：场上1个超量素材取除，从自己卡组上面把4张卡翻开，从那之中选1张。那张卡种类的以下效果适用。剩下的卡用原本的顺序回到卡组上面。
-- ●怪兽·魔法：选的卡加入手卡。
-- ●陷阱：选的卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
local s,id,o=GetID()
-- 创建并注册「傀儡鲨」的魔法卡效果：设置效果描述、效果分类（回手/检索/盖放）、发动类型为魔法卡发动、自由时点发动、同名卡1回合1次限制，并指定发动条件与处理函数。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：场上1个超量素材取除，从自己卡组上面把4张卡翻开，从那之中选1张。那张卡种类的以下效果适用。剩下的卡用原本的顺序回到卡组上面。●怪兽·魔法：选的卡加入手卡。●陷阱：选的卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
-- 设定效果的发动条件：在发动时确认可以取除场上1个超量素材，并且自己卡组至少有4张卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 具体判定：检查我方能否以效果原因取除场上合计1个超量素材，且自己卡组数量≥4。
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=4 end
end
-- 定义可选卡筛选函数：从卡组顶翻开的卡中选出可处理的卡——陷阱卡（且魔陷区有空位可盖放），或怪兽/魔法卡（且满足能加入手卡的条件）。
function s.thfilter(c,tp)
	-- 筛选条件之一：该卡是陷阱卡，且我方魔陷区有空位。
	return c:IsType(TYPE_TRAP) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		or c:IsType(TYPE_MONSTER+TYPE_SPELL) and c:IsAbleToHand()
end
-- 执行效果：先取除场上1个超量素材；成功后确认卡组顶4张，筛选出符合条件的卡；若存在，则由玩家选择1张；根据其种类，陷阱卡盖放到我方场上并赋予当回合可发动的效果，怪兽/魔法卡加入手卡并向对方展示、洗切手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 以效果原因从场上取除1个超量素材，若取除成功则继续后续处理。
	if Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_EFFECT)~=0 then
		-- 展示自己卡组最上方4张卡给双方确认。
		Duel.ConfirmDecktop(tp,4)
		-- 获取卡组最上方4张卡，并筛选出满足s.thfilter条件的卡（陷阱且可盖放，或怪兽/魔法且可加入手卡）。
		local g=Duel.GetDecktopGroup(tp,4):Filter(s.thfilter,nil,tp)
		if #g>0 then
			-- 禁用系统自动洗牌检测，因为后续卡组顶的卡返回或检索不需要额外的洗牌。
			Duel.DisableShuffleCheck()
			-- 弹出选择卡片的提示消息，提示玩家选择一张要操作的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
			-- 开始播放从卡组顶选择卡片的演出过程（进入选择展示状态）。
			Duel.RevealSelectDeckSequence(true)
			local sc=g:Select(tp,1,1,nil):GetFirst()
			-- 结束从卡组顶选择卡片的演出过程（退出选择展示状态）。
			Duel.RevealSelectDeckSequence(false)
			if sc:IsType(TYPE_TRAP) then
				-- 将选择的陷阱卡盖放到我方魔陷区；若盖放成功，则继续给该卡附加当回合可发动的效果。
				if Duel.SSet(tp,sc)>0 then
					-- ●陷阱：选的卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
					local e1=Effect.CreateEffect(c)
					e1:SetDescription(aux.Stringid(id,1))  --"适用「傀儡流仪-傀儡鲨」的效果来发动"
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
					e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					sc:RegisterEffect(e1)
				end
			else
				-- 将选择的怪兽或魔法卡以效果原因加入手卡。
				Duel.SendtoHand(sc,nil,REASON_EFFECT)
				-- 将加入手卡的卡展示给对方玩家确认。
				Duel.ConfirmCards(1-tp,sc)
				-- 洗切自己的手卡，使对方无法确定加入手卡的是哪一张。
				Duel.ShuffleHand(tp)
			end
		end
	end
end
