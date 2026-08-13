--魔導書庫ソレイン
-- 效果：
-- 自己墓地的名字带有「魔导书」的魔法卡是5张以上的场合才能发动。从自己卡组上面把2张卡翻开。那之中的名字带有「魔导书」的魔法卡全部加入手卡，剩下的卡回到卡组。「魔导书库 苏雷」在1回合只能发动1张，这张卡发动的回合，自己不能把名字带有「魔导书」的卡以外的魔法卡发动。
function c20822520.initial_effect(c)
	-- 自己墓地的名字带有「魔导书」的魔法卡是5张以上的场合才能发动。从自己卡组上面把2张卡翻开。那之中的名字带有「魔导书」的魔法卡全部加入手卡，剩下的卡回到卡组。「魔导书库 苏雷」在1回合只能发动1张，这张卡发动的回合，自己不能把名字带有「魔导书」的卡以外的魔法卡发动。
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
		-- 自己墓地的名字带有「魔导书」的魔法卡是5张以上的场合才能发动。……这张卡发动的回合，自己不能把名字带有「魔导书」的卡以外的魔法卡发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(c20822520.checkop)
		-- 将全局检测效果ge1注册到全场（控制者0），使其持续监听双方的魔法卡发动事件，用于记录本回合是否发动过非「魔导书」的魔法卡。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 当有魔法卡发动时，检查该发动是否为魔法卡的发动且不属于「魔导书」字段；若是，则为发动者注册一个编号20822521的回合标志，记录其本回合已发动过非「魔导书」的魔法卡。
function c20822520.checkop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and not re:GetHandler():IsSetCard(0x106e) then
		-- 为玩家rp注册标志效果（编号20822521，结束阶段重置），表示该玩家本回合发动过非「魔导书」的魔法卡，用于后续禁止继续发动非「魔导书」魔法卡。
		Duel.RegisterFlagEffect(rp,20822521,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 过滤函数：判断一张卡是否为名字带有「魔导书」的魔法卡，即类型为魔法卡且属于字段0x106e。
function c20822520.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(0x106e)
end
-- 发动条件判断函数：只有自己墓地存在5张以上满足cfilter过滤条件的「魔导书」魔法卡时，本卡才能发动。
function c20822520.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的墓地是否存在至少5张「魔导书」魔法卡（使用cfilter过滤），存在则返回true，否则不能发动。
	return Duel.IsExistingMatchingCard(c20822520.cfilter,tp,LOCATION_GRAVE,0,5,nil)
end
-- 发动代价处理：先确认本回合没有发动过非「魔导书」魔法卡（无标志20822521）；通过后给自己场地区域注册一个誓约效果，使本回合不能再发动非「魔导书」的魔法卡。
function c20822520.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检查阶段（chk==0），若自己拥有标志20822521（表示本回合已发动过非「魔导书」魔法卡），则无法支付代价，返回false；否则返回true。
	if chk==0 then return Duel.GetFlagEffect(tp,20822521)==0 end
	-- 从自己卡组上面把2张卡翻开。那之中的名字带有「魔导书」的魔法卡全部加入手卡，剩下的卡回到卡组。这张卡发动的回合，自己不能把名字带有「魔导书」的卡以外的魔法卡发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c20822520.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将刚创建的对玩家自身起作用的“不能发动非「魔导书」魔法卡”的誓约效果注册给玩家tp，该效果持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 限制判定函数：当玩家尝试发动魔法卡时，如果该发动不是「魔导书」字段的魔法卡发动，则返回true，表示该发动被禁止。
function c20822520.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and not re:GetHandler():IsSetCard(0x106e)
end
-- 目标选择函数：确认卡组至少2张且翻开前2张中存在至少1张能加入手卡的卡；然后设定本连锁的对象玩家为自己，并声明操作类别为从卡组加入手卡。
function c20822520.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 若自己的卡组不足2张，则无法发动，返回false。
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<2 then return false end
		-- 获取自己卡组最上方的2张卡，放入临时组g中。
		local g=Duel.GetDecktopGroup(tp,2)
		return g:FilterCount(Card.IsAbleToHand,nil)>0
	end
	-- 将当前连锁的处理对象玩家设为自己（tp），这样处理阶段从目标玩家的卡组顶翻开卡片。
	Duel.SetTargetPlayer(tp)
	-- 设置连锁操作信息：本效果涉及从卡组把卡加入手卡（目标数为1，位置为卡组），以便系统识别“检索/加入手卡”相关判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 过滤函数：在翻开的2张卡中筛选出名字带有「魔导书」的魔法卡（类型为魔法卡且字段为0x106e）。
function c20822520.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(0x106e)
end
-- 效果处理：翻开对象玩家的卡组顶2张，筛选其中的「魔导书」魔法卡；能加入手卡的加入手卡并让对方确认，不能加入的则送去墓地，其余非「魔导书」卡通过洗切卡组回到卡组。
function c20822520.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取效果发动时设定的对象玩家p，即要处理哪个玩家的卡组。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 让对象玩家p确认其卡组最上方的2张牌（展示给双方）。
	Duel.ConfirmDecktop(p,2)
	-- 获取对象玩家p卡组最上方的2张卡，存入g。
	local g=Duel.GetDecktopGroup(p,2)
	if g:GetCount()>0 then
		local sg=g:Filter(c20822520.filter,nil)
		if sg:GetCount()>0 then
			if sg:GetFirst():IsAbleToHand() then
				-- 将筛选出的「魔导书」魔法卡sg以效果原因送入其持有者的手卡（player参数为nil表示回持有者手卡）。
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				-- 把加入手卡的sg展示给对方玩家（1-p），确认检索到的卡片。
				Duel.ConfirmCards(1-p,sg)
				-- 洗切对象玩家p的手牌（因为从卡组加入了手卡，手牌顺序可能被确认，需要洗牌）。
				Duel.ShuffleHand(p)
			else
				-- 若选中的「魔导书」魔法卡不能加入手卡，则将它们全部以效果原因送去墓地。
				Duel.SendtoGrave(sg,REASON_EFFECT)
			end
		end
		-- 洗切对象玩家p的卡组，使未加入手卡/未离开卡组的部分（即“剩下的卡”）回到卡组并随机化。
		Duel.ShuffleDeck(p)
	end
end
