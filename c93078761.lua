--賽挑戦
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：掷1次骰子，1·6出现的场合，把持有掷骰子效果的1张卡从卡组加入手卡。1·6以外出现的场合，再掷1次骰子，出现数目的以下效果适用。
-- ●1·6：场上的这张卡回到持有者手卡。
-- ●2～5：场上的这张卡回到持有者卡组最上面。
function c93078761.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：掷1次骰子，1·6出现的场合，把持有掷骰子效果的1张卡从卡组加入手卡。1·6以外出现的场合，再掷1次骰子，出现数目的以下效果适用。●1·6：场上的这张卡回到持有者手卡。●2～5：场上的这张卡回到持有者卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DICE+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCountLimit(1,93078761+EFFECT_COUNT_CODE_OATH)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c93078761.target)
	e1:SetOperation(c93078761.activate)
	c:RegisterEffect(e1)
end
-- 定义卡组检索的过滤条件函数
function c93078761.filter(c)
	-- 检查卡片是否具有掷骰子的效果属性，且可以加入手牌
	return c:IsEffectProperty(aux.EffectPropertyFilter(EFFECT_FLAG_DICE)) and c:IsAbleToHand()
end
-- 定义效果发动的合法性检测函数
function c93078761.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检测卡组中是否存在至少1张满足条件的、可检索的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c93078761.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 定义效果发动的具体处理函数
function c93078761.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 进行第1次掷骰子，并记录结果
	local dice1=Duel.TossDice(tp,1)
	if (dice1==1 or dice1==6) then
		-- 在客户端显示“请选择要加入手牌的卡”的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组中选择1张满足过滤条件的卡片
		local tc=Duel.SelectMatchingCard(tp,c93078761.filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		if tc then
			-- 将选中的卡片加入玩家手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手牌的卡片
			Duel.ConfirmCards(1-tp,tc)
		end
		return
	elseif c:IsRelateToEffect(e) then
		-- 进行第2次掷骰子，并记录结果
		local dice2=Duel.TossDice(tp,1)
		if (dice2==1 or dice2==6) then
			c:CancelToGrave()
			-- 将场上的这张卡送回持有者的手牌
			Duel.SendtoHand(c,nil,REASON_EFFECT)
		elseif dice2>=2 and dice2<=5 then
			c:CancelToGrave()
			-- 将场上的这张卡送回持有者卡组的最上方
			Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	end
end
