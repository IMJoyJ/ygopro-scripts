--白銀の城の召使い アリアンナ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「白银之城的召使 阿里安娜」以外的1张「拉比林斯迷宫」卡加入手卡。
-- ②：自己的通常陷阱卡的效果让怪兽从场上离开的场合才能发动。自己从卡组抽1张。那之后，以下效果可以适用。
-- ●从手卡把1只恶魔族怪兽特殊召唤或把1张魔法·陷阱卡盖放。
function c1225009.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：这张卡召唤的场合才能发动。从卡组把「白银之城的召使 阿里安娜」以外的1张「拉比林斯迷宫」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1225009,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,1225009)
	e1:SetTarget(c1225009.thtg)
	e1:SetOperation(c1225009.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：自己的通常陷阱卡的效果让怪兽从场上离开的场合才能发动。自己抽1张。那之后，以下效果可以适用。●从手卡把1只恶魔族怪兽特殊召唤或把1张魔法·陷阱卡盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1225009,1))  --"抽卡"
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,1225009)
	e3:SetCondition(c1225009.drcon)
	e3:SetTarget(c1225009.drtg)
	e3:SetOperation(c1225009.drop)
	c:RegisterEffect(e3)
end
-- 筛选条件：属于「拉比林斯迷宫」字段（0x17e）、卡名不是「白银之城的召使 阿里安娜」自身、并且能够加入手卡。
function c1225009.thfilter(c)
	return c:IsSetCard(0x17e) and not c:IsCode(1225009) and c:IsAbleToHand()
end
-- 效果发动时的目标判定和操作信息设置：检查卡组中是否存在满足检索条件的「拉比林斯迷宫」卡，若有则登记本次检索加入手卡的操作信息。
function c1225009.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件确认：己方卡组中存在至少1张满足筛选条件的「拉比林斯迷宫」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c1225009.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果的操作信息：将卡组中的1张卡加入手卡，分类为CATEGORY_TOHAND，供后续连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1张符合条件的「拉比林斯迷宫」卡加入手卡，然后展示给对方玩家确认。
function c1225009.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：让当前玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足筛选条件的卡。
	local g=Duel.SelectMatchingCard(tp,c1225009.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判定离场怪兽是否此前位于主要怪兽区，并且离场原因为效果（即由效果导致离场）。
function c1225009.cfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT)
end
-- 发动条件判定：存在连锁原因，且是己方发动的通常陷阱卡效果（原种类为陷阱），并且该效果导致了满足cfilter条件的怪兽离场。
function c1225009.drcon(e,tp,eg,ep,ev,re,r,rp)
	return re and rp==tp and re:IsActiveType(TYPE_TRAP) and re:GetHandler():GetOriginalType()==TYPE_TRAP
		and eg:IsExists(c1225009.cfilter,1,nil)
end
-- 发动时的目标/参数设置：确认己方可以抽1张卡，将连锁对象玩家设为己方、抽卡数设为1，并登记抽卡操作信息。
function c1225009.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方是否允许抽1张卡，作为发动条件。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设为己方，供后续处理时获取抽卡玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设为1，表示预定抽卡张数为1。
	Duel.SetTargetParam(1)
	-- 登记抽卡操作信息，用于连锁中判定这是抽卡效果。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 筛选手牌中种族为恶魔族且能够被特殊召唤的怪兽卡。
function c1225009.spfilter2(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：先让己方抽1张卡，若抽卡成功，则在“从手卡特殊召唤恶魔族怪兽”“从手卡盖放魔法·陷阱卡”“什么都不做”中选择一项并执行对应操作。
function c1225009.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的对象玩家和参数，即抽卡玩家和抽卡张数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 实际执行抽卡，若成功抽到至少1张卡才继续后续的选项处理。
	if Duel.Draw(p,d,REASON_EFFECT)>0 then
		local off=1
		local ops={}
		local opval={}
		-- 获取己方手牌中可作为特殊召唤候选的恶魔族怪兽集合。
		local spg=Duel.GetMatchingGroup(c1225009.spfilter2,tp,LOCATION_HAND,0,nil,e,tp)
		-- 获取己方手牌中可作为盖放候选的魔法·陷阱卡集合。
		local stg=Duel.GetMatchingGroup(Card.IsSSetable,tp,LOCATION_HAND,0,nil)
		-- 存在可特殊召唤的恶魔族怪兽且己方主要怪兽区有空位时，才提供“特殊召唤”选项。
		if #spg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			ops[off]=aux.Stringid(1225009,2)  --"从手卡特殊召唤"
			opval[off-1]=1
			off=off+1
		end
		if #stg>0 then
			ops[off]=aux.Stringid(1225009,3)  --"从手卡盖放"
			opval[off-1]=2
			off=off+1
		end
		ops[off]=aux.Stringid(1225009,4)  --"什么都不做"
		opval[off-1]=0
		-- 弹出发动玩家的选择菜单，返回值是所选选项的序号。
		local op=Duel.SelectOption(tp,table.unpack(ops))
		if opval[op]==1 then
			-- 中断当前效果链，使后续特殊召唤处理作为独立时点处理，避免错过时点。
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=spg:Select(tp,1,1,nil)
			-- 将选择的恶魔族怪兽以表侧表示特殊召唤到己方场上。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
		if opval[op]==2 then
			-- 中断当前效果链，使后续盖放处理作为独立时点处理，避免错过时点。
			Duel.BreakEffect()
			-- 提示玩家选择要盖放的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			local sg=stg:Select(tp,1,1,nil)
			-- 将选择的魔法·陷阱卡盖放到己方场上。
			Duel.SSet(tp,sg,tp,false)
		end
	end
end
