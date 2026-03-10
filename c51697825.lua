--ジャック・イン・ザ・ハンド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把3只卡名不同的1星怪兽给对方观看，对方从那之中选1只加入自身手卡。自己从剩下的卡之中选1只加入手卡，剩余回到卡组。
function c51697825.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,51697825+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c51697825.target)
	e1:SetOperation(c51697825.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：筛选满足条件的1星怪兽，这些怪兽可以送去手卡且对方也能送去手卡。
function c51697825.thfilter(c,tp)
	return c:IsLevel(1) and c:IsAbleToHand() and c:IsAbleToHand(1-tp)
end
-- 效果作用：检查是否满足条件（至少有3张不同卡名的1星怪兽），并设置操作信息。
function c51697825.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：获取满足条件的卡组中的所有1星怪兽。
	local g=Duel.GetMatchingGroup(c51697825.thfilter,tp,LOCATION_DECK,0,nil,tp)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=3 end
	-- 效果作用：设置连锁处理中将要处理的卡的数量和位置。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,PLAYER_ALL,LOCATION_DECK)
end
-- 效果作用：主处理函数，执行从卡组选择并分配卡牌给双方手牌的操作。
function c51697825.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：再次获取满足条件的卡组中的所有1星怪兽。
	local g=Duel.GetMatchingGroup(c51697825.thfilter,tp,LOCATION_DECK,0,nil,tp)
	-- 效果作用：提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 效果作用：从符合条件的卡中选择3张不同卡名的卡组成子组。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
	if sg then
		-- 效果作用：向对方确认展示所选的卡。
		Duel.ConfirmCards(1-tp,sg)
		-- 效果作用：提示对方玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local oc=sg:Select(1-tp,1,1,nil):GetFirst()
		oc:SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 效果作用：将选定的卡送入对方手牌，并判断是否成功送入。
		if Duel.SendtoHand(oc,1-tp,REASON_EFFECT)~=0 and oc:IsLocation(LOCATION_HAND) then
			sg:RemoveCard(oc)
			-- 效果作用：提示己方玩家选择要加入手牌的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sc=sg:Select(tp,1,1,nil):GetFirst()
			sc:SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
			-- 效果作用：将选定的卡送入己方手牌。
			Duel.SendtoHand(sc,tp,REASON_EFFECT)
		end
	end
end
