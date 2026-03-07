--天地開闢
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把包含「混沌战士」怪兽或者「暗黑骑士 盖亚」怪兽1只以上的3只战士族怪兽给对方观看，对方从那之中随机选1只。那是「混沌战士」怪兽或者「暗黑骑士 盖亚」怪兽的场合，那只怪兽加入自己手卡，剩下的卡全部送去墓地。不是的场合，给对方观看的卡全部送去墓地。
function c32360466.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,32360466+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c32360466.target)
	e1:SetOperation(c32360466.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：筛选出卡组中满足条件的战士族怪兽（可加入手牌）
function c32360466.filter1(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
-- 效果作用：筛选出包含「混沌战士」或「暗黑骑士 盖亚」的怪兽
function c32360466.filter2(c)
	return c:IsSetCard(0x10cf,0xbd)
end
-- 效果作用：判断是否满足发动条件（卡组中存在3只以上战士族怪兽且其中至少1只为指定种族）
function c32360466.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 效果作用：检查玩家是否可以将卡组顶端1张卡送去墓地
		if not Duel.IsPlayerCanDiscardDeck(tp,1) then return false end
		-- 效果作用：获取满足战士族且可加入手牌的卡组卡片
		local g=Duel.GetMatchingGroup(c32360466.filter1,tp,LOCATION_DECK,0,nil)
		return g:GetCount()>2 and g:IsExists(c32360466.filter2,1,nil)
	end
	-- 效果作用：设置连锁处理信息，表示将要处理的卡为1张加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 效果作用：处理发动效果，执行主要流程
function c32360466.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查玩家是否可以将卡组顶端1张卡送去墓地
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 效果作用：获取满足战士族且可加入手牌的卡组卡片
	local g=Duel.GetMatchingGroup(c32360466.filter1,tp,LOCATION_DECK,0,nil)
	if g:IsExists(c32360466.filter2,1,nil) then
		-- 效果作用：提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg1=g:FilterSelect(tp,c32360466.filter2,1,1,nil)
		g:RemoveCard(sg1:GetFirst())
		-- 效果作用：提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg2=g:Select(tp,2,2,nil)
		sg1:Merge(sg2)
		-- 效果作用：向对方确认所选的3只怪兽
		Duel.ConfirmCards(1-tp,sg1)
		-- 效果作用：将卡组洗切
		Duel.ShuffleDeck(tp)
		local tg=sg1:Select(1-tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 效果作用：提示对方所选的卡的卡号
		Duel.Hint(HINT_CARD,0,tc:GetCode())
		if c32360466.filter2(tc) and tc:IsAbleToHand() then
			tc:SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
			-- 效果作用：将符合条件的怪兽加入自己手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			sg1:RemoveCard(tc)
		end
		-- 效果作用：将剩余的怪兽全部送去墓地
		Duel.SendtoGrave(sg1,REASON_EFFECT)
	end
end
