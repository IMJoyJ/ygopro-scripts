--傀儡流儀－パペット・シャーク
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：场上1个超量素材取除，从自己卡组上面把4张卡翻开，从那之中选1张。那张卡种类的以下效果适用。剩下的卡用原本的顺序回到卡组上面。
-- ●怪兽·魔法：选的卡加入手卡。
-- ●陷阱：选的卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
local s,id,o=GetID()
-- 创建效果，设置发动条件和处理流程
function s.initial_effect(c)
	-- ①：场上1个超量素材取除，从自己卡组上面把4张卡翻开，从那之中选1张。那张卡种类的以下效果适用。剩下的卡用原本的顺序回到卡组上面。
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
-- 判断是否满足发动条件：是否有足够的超量素材可移除且卡组至少有4张牌
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能移除1个超量素材并确认卡组有至少4张牌
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=4 end
end
-- 筛选符合条件的卡片（陷阱卡可盖放，怪兽/魔法卡可加入手牌）
function s.thfilter(c,tp)
	-- 判断卡片是否为陷阱卡且场上魔陷区有空位
	return c:IsType(TYPE_TRAP) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		or c:IsType(TYPE_MONSTER+TYPE_SPELL) and c:IsAbleToHand()
end
-- 处理效果发动的主要逻辑：移除超量素材、翻开卡组顶部4张牌并选择一张进行操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 成功移除1个超量素材后执行后续操作
	if Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_EFFECT)~=0 then
		-- 确认玩家卡组最上方的4张牌
		Duel.ConfirmDecktop(tp,4)
		-- 获取卡组顶部4张牌中符合条件的卡片组成过滤器
		local g=Duel.GetDecktopGroup(tp,4):Filter(s.thfilter,nil,tp)
		if #g>0 then
			-- 禁用洗切卡组检测，防止后续操作自动洗牌
			Duel.DisableShuffleCheck()
			-- 提示玩家选择要操作的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
			-- 显示选卡动画并等待玩家选择
			Duel.RevealSelectDeckSequence(true)
			local sc=g:Select(tp,1,1,nil):GetFirst()
			-- 结束选卡动画
			Duel.RevealSelectDeckSequence(false)
			if sc:IsType(TYPE_TRAP) then
				-- 若选择的是陷阱卡，则在场上盖放该陷阱卡
				if Duel.SSet(tp,sc)>0 then
					-- 这个效果盖放的卡在盖放的回合也能发动。
					local e1=Effect.CreateEffect(c)
					e1:SetDescription(aux.Stringid(id,1))  --"适用「傀儡流仪-傀儡鲨」的效果来发动"
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
					e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					sc:RegisterEffect(e1)
				end
			else
				-- 若选择的是怪兽或魔法卡，则加入手牌
				Duel.SendtoHand(sc,nil,REASON_EFFECT)
				-- 向对方确认所选卡片
				Duel.ConfirmCards(1-tp,sc)
				-- 手动洗切自己的手牌
				Duel.ShuffleHand(tp)
			end
		end
	end
end
