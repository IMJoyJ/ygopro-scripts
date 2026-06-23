--星遺物の醒存
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己卡组上面把5张卡翻开。那之中有「机怪虫」怪兽或者「星遗物」卡的场合，选那之内的1张加入手卡，剩下的卡全部送去墓地。没有的场合，翻开的卡全部回到卡组。这张卡的发动后，直到回合结束时自己不是连接怪兽不能从额外卡组特殊召唤。
function c31706048.initial_effect(c)
	-- 创建效果，设置效果分类为回手牌、检索和卡组破坏，效果类型为发动，时点为自由连锁，发动次数限制为1次，设置目标函数和发动函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,31706048+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c31706048.target)
	e1:SetOperation(c31706048.activate)
	c:RegisterEffect(e1)
end
-- 判断是否可以翻开5张卡并确认卡组顶部是否有能加入手牌的卡
function c31706048.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以将卡组顶端5张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,5)
		-- 确认卡组顶部5张卡中是否存在能加入手牌的卡
		and Duel.GetDecktopGroup(tp,5):FilterCount(Card.IsAbleToHand,nil)>0 end
	-- 设置连锁操作信息，指定将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 定义过滤函数，用于筛选「机怪虫」怪兽或「星遗物」卡
function c31706048.filter(c)
	return (c:IsSetCard(0x104) and c:IsType(TYPE_MONSTER)) or c:IsSetCard(0xfe) and c:IsAbleToHand()
end
-- 发动效果函数，执行翻开卡组顶部5张卡的操作，根据是否有符合条件的卡决定处理方式
function c31706048.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否可以将卡组顶端5张卡送去墓地
	if Duel.IsPlayerCanDiscardDeck(tp,5) then
		-- 确认玩家卡组最上方的5张卡
		Duel.ConfirmDecktop(tp,5)
		-- 获取玩家卡组最上方的5张卡组成的组
		local g=Duel.GetDecktopGroup(tp,5)
		if g:GetCount()>0 then
			if g:IsExists(c31706048.filter,1,nil) then
				-- 禁用后续操作的洗卡检测
				Duel.DisableShuffleCheck()
				-- 提示玩家选择要加入手牌的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				local sg=g:FilterSelect(tp,c31706048.filter,1,1,nil)
				-- 将选择的卡加入手牌
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				-- 向对方确认选择的卡
				Duel.ConfirmCards(1-tp,sg)
				-- 洗切玩家手牌
				Duel.ShuffleHand(tp)
				g:Sub(sg)
				-- 将剩余的卡送去墓地
				Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
			else
				-- 将玩家卡组洗切
				Duel.ShuffleDeck(tp)
			end
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 创建永续效果，禁止玩家在回合结束前从额外卡组特殊召唤非连接怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c31706048.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 定义特殊召唤限制函数，禁止非连接怪兽从额外卡组特殊召唤
function c31706048.splimit(e,c)
	return not c:IsType(TYPE_LINK) and c:IsLocation(LOCATION_EXTRA)
end
