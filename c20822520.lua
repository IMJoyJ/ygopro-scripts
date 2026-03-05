--魔導書庫ソレイン
-- 效果：
-- 自己墓地的名字带有「魔导书」的魔法卡是5张以上的场合才能发动。从自己卡组上面把2张卡翻开。那之中的名字带有「魔导书」的魔法卡全部加入手卡，剩下的卡回到卡组。「魔导书库 苏雷」在1回合只能发动1张，这张卡发动的回合，自己不能把名字带有「魔导书」的卡以外的魔法卡发动。
function c20822520.initial_effect(c)
	-- 效果原文内容：自己墓地的名字带有「魔导书」的魔法卡是5张以上的场合才能发动。从自己卡组上面把2张卡翻开。那之中的名字带有「魔导书」的魔法卡全部加入手卡，剩下的卡回到卡组。「魔导书库 苏雷」在1回合只能发动1张，这张卡发动的回合，自己不能把名字带有「魔导书」的卡以外的魔法卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,20822520+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c20822520.condition)
	e1:SetCost(c20822520.cost)
	e1:SetTarget(c20822520.target)
	e1:SetOperation(c20822520.activate)
	c:RegisterEffect(e1)
	if not c20822520.global_check then
		c20822520.global_check=true
		-- 效果原文内容：自己墓地的名字带有「魔导书」的魔法卡是5张以上的场合才能发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(c20822520.checkop)
		-- 注册一个全局连续型效果，用于检测连锁时是否发动了非魔导书的魔法卡。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 当有魔法卡发动时，检查该卡是否为魔法卡且不是魔导书卡组，若是则为发动玩家注册标识效果。
function c20822520.checkop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and not re:GetHandler():IsSetCard(0x106e) then
		-- 为玩家注册一个标识效果，表示该玩家在本回合已发动过魔导书库苏雷的效果。
		Duel.RegisterFlagEffect(rp,20822521,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 过滤函数，用于判断一张卡是否为魔导书卡组的魔法卡。
function c20822520.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(0x106e)
end
-- 判断发动条件：自己墓地是否存在至少5张魔导书魔法卡。
function c20822520.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在至少5张魔导书魔法卡。
	return Duel.IsExistingMatchingCard(c20822520.cfilter,tp,LOCATION_GRAVE,0,5,nil)
end
-- 设置发动费用：若本回合未发动过魔导书库苏雷，则不能发动非魔导书魔法卡。
function c20822520.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否已发动过魔导书库苏雷的效果。
	if chk==0 then return Duel.GetFlagEffect(tp,20822521)==0 end
	-- 创建并注册一个禁止发动魔法卡的效果，防止在本回合发动非魔导书魔法卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c20822520.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将禁止发动魔法卡的效果注册给当前玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果函数，用于判断是否为非魔导书魔法卡的发动。
function c20822520.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and not re:GetHandler():IsSetCard(0x106e)
end
-- 设置发动目标：检查卡组是否至少有2张卡，然后确认卡组最上方2张卡中是否有可回手的魔导书魔法卡。
function c20822520.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己卡组是否至少有2张卡。
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<2 then return false end
		-- 获取自己卡组最上方的2张卡。
		local g=Duel.GetDecktopGroup(tp,2)
		return g:FilterCount(Card.IsAbleToHand,nil)>0
	end
	-- 设置连锁的目标玩家为当前玩家。
	Duel.SetTargetPlayer(tp)
	-- 设置连锁操作信息，表示将要处理的卡是卡组最上方的卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 过滤函数，用于判断一张卡是否为魔导书魔法卡。
function c20822520.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(0x106e)
end
-- 发动效果：翻开自己卡组最上方2张卡，将其中魔导书魔法卡加入手牌，其余卡返回卡组。
function c20822520.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 确认玩家卡组最上方的2张卡。
	Duel.ConfirmDecktop(p,2)
	-- 获取玩家卡组最上方的2张卡。
	local g=Duel.GetDecktopGroup(p,2)
	if g:GetCount()>0 then
		local sg=g:Filter(c20822520.filter,nil)
		if sg:GetCount()>0 then
			if sg:GetFirst():IsAbleToHand() then
				-- 将符合条件的魔导书魔法卡送入手牌。
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				-- 确认对手查看这些送入手牌的卡。
				Duel.ConfirmCards(1-p,sg)
				-- 洗切玩家的手牌。
				Duel.ShuffleHand(p)
			else
				-- 将不符合条件的魔导书魔法卡送入墓地。
				Duel.SendtoGrave(sg,REASON_EFFECT)
			end
		end
		-- 洗切玩家的卡组。
		Duel.ShuffleDeck(p)
	end
end
