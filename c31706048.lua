--星遺物の醒存
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己卡组上面把5张卡翻开。那之中有「机怪虫」怪兽或者「星遗物」卡的场合，选那之内的1张加入手卡，剩下的卡全部送去墓地。没有的场合，翻开的卡全部回到卡组。这张卡的发动后，直到回合结束时自己不是连接怪兽不能从额外卡组特殊召唤。
function c31706048.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己卡组上面把5张卡翻开。那之中有「机怪虫」怪兽或者「星遗物」卡的场合，选那之内的1张加入手卡，剩下的卡全部送去墓地。没有的场合，翻开的卡全部回到卡组。这张卡的发动后，直到回合结束时自己不是连接怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,31706048+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c31706048.target)
	e1:SetOperation(c31706048.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定函数：在发动时确认自己可以把卡组顶端5张卡送去墓地，并且这5张卡中存在至少1张可以加入手卡的卡，满足条件才允许发动。
function c31706048.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查（chk==0）时，要求自己必须能把卡组最上方5张卡送去墓地（即卡组足够且没有送墓限制）。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,5)
		-- 同时要求卡组顶端5张卡中至少有1张卡能够加入手卡，作为后续“选那之内的1张加入手卡”的检索前提。
		and Duel.GetDecktopGroup(tp,5):FilterCount(Card.IsAbleToHand,nil)>0 end
	-- 向系统登记本次操作信息：这是从卡组将1张卡加入手卡的检索效果（CATEGORY_TOHAND），用于满足相关卡片的发动判定与连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 定义符合条件的卡片筛选函数：翻开的卡中，是「机怪虫」怪兽，或者「星遗物」卡且能够加入手卡的卡。
function c31706048.filter(c)
	return (c:IsSetCard(0x104) and c:IsType(TYPE_MONSTER)) or c:IsSetCard(0xfe) and c:IsAbleToHand()
end
-- 效果处理整体流程：确认卡组顶端5张卡；若其中有符合条件的卡，则选1张加入手卡、其余送去墓地；若没有则将翻开的卡洗回卡组；最后适用“直到回合结束时自己不是连接怪兽不能从额外卡组特殊召唤”的自肃效果。
function c31706048.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认玩家可以把卡组顶端5张卡送去墓地，以防止处理时情况变化导致无法执行翻卡操作。
	if Duel.IsPlayerCanDiscardDeck(tp,5) then
		-- 翻开自己卡组最上方5张卡，向双方玩家公开确认这些卡的内容。
		Duel.ConfirmDecktop(tp,5)
		-- 获取被翻开的那5张卡，作为一个卡片组g，用于后续的筛选和移动。
		local g=Duel.GetDecktopGroup(tp,5)
		if g:GetCount()>0 then
			if g:IsExists(c31706048.filter,1,nil) then
				-- 关闭本次后续操作的自动洗牌检测，因为本效果按顺序执行翻卡、加入手卡、送墓/洗回卡组，不应在中间触发系统自动洗切卡组。
				Duel.DisableShuffleCheck()
				-- 向玩家显示“请选择要加入手牌的卡”的选择提示，并将该消息作为后续选择卡片的提示缓存。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				local sg=g:FilterSelect(tp,c31706048.filter,1,1,nil)
				-- 将选择的那1张卡片加入其持有者的手卡（此处为自己），移动原因视为效果处理。
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				-- 将刚刚加入手卡的那张卡片展示给对方玩家确认，使对方知晓加入手卡的卡是哪一张。
				Duel.ConfirmCards(1-tp,sg)
				-- 洗切自己的手卡，使加入的卡片随机混入手牌，避免被对方通过手牌位置获取额外信息。
				Duel.ShuffleHand(tp)
				g:Sub(sg)
				-- 将翻开后未被选择的剩余卡片全部送去墓地，处理原因包含效果处理和翻开（REASON_EFFECT+REASON_REVEAL）。
				Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
			else
				-- 当翻开的5张卡中没有符合条件的卡时，将翻开的卡片全部洗回自己的卡组。
				Duel.ShuffleDeck(tp)
			end
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时自己不是连接怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c31706048.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果e1注册到当前决斗中，使其从现在开始持续影响到结束阶段，限制自己从额外卡组特殊召唤非连接怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的判定条件：被特殊召唤的怪兽来自额外卡组且不是连接怪兽时，禁止该特殊召唤。
function c31706048.splimit(e,c)
	return not c:IsType(TYPE_LINK) and c:IsLocation(LOCATION_EXTRA)
end
