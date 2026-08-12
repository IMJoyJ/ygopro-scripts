--白銀の城の召使い アリアンナ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「白银之城的召使 阿里安娜」以外的1张「拉比林斯迷宫」卡加入手卡。
-- ②：自己的通常陷阱卡的效果让怪兽从场上离开的场合才能发动。自己从卡组抽1张。那之后，以下效果可以适用。
-- ●从手卡把1只恶魔族怪兽特殊召唤或把1张魔法·陷阱卡盖放。
function c1225009.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「白银之城的召使 阿里安娜」以外的1张「拉比林斯迷宫」卡加入手卡。
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
	-- ②：自己的通常陷阱卡的效果让怪兽从场上离开的场合才能发动。自己从卡组抽1张。那之后，以下效果可以适用。●从手卡把1只恶魔族怪兽特殊召唤或把1张魔法·陷阱卡盖放。
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
-- 检索过滤函数，用于筛选「拉比林斯迷宫」卡且排除阿里安娜自身
function c1225009.thfilter(c)
	return c:IsSetCard(0x17e) and not c:IsCode(1225009) and c:IsAbleToHand()
end
-- 效果处理时的检索目标设定函数
function c1225009.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件，即卡组中是否存在符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c1225009.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的检索执行函数
function c1225009.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组中选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c1225009.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断怪兽离开场上的条件过滤函数
function c1225009.cfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT)
end
-- 判断是否满足抽卡条件，即是否为己方陷阱卡的效果使怪兽离场
function c1225009.drcon(e,tp,eg,ep,ev,re,r,rp)
	return re and rp==tp and re:IsActiveType(TYPE_TRAP) and re:GetHandler():GetOriginalType()==TYPE_TRAP
		and eg:IsExists(c1225009.cfilter,1,nil)
end
-- 效果处理时的抽卡目标设定函数
function c1225009.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁操作信息，指定抽卡对象为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁操作信息，指定抽卡数量为1张
	Duel.SetTargetParam(1)
	-- 设置连锁操作信息，指定抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 特殊召唤过滤函数，用于筛选恶魔族怪兽
function c1225009.spfilter2(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时的抽卡后处理函数
function c1225009.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作，若成功则继续后续处理
	if Duel.Draw(p,d,REASON_EFFECT)>0 then
		local off=1
		local ops={}
		local opval={}
		-- 获取满足特殊召唤条件的手牌怪兽组
		local spg=Duel.GetMatchingGroup(c1225009.spfilter2,tp,LOCATION_HAND,0,nil,e,tp)
		-- 获取可盖放的手牌魔法·陷阱卡组
		local stg=Duel.GetMatchingGroup(Card.IsSSetable,tp,LOCATION_HAND,0,nil)
		-- 判断是否满足特殊召唤条件，即手牌中有恶魔族怪兽且场上存在空位
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
		-- 让玩家选择后续处理方式
		local op=Duel.SelectOption(tp,table.unpack(ops))
		if opval[op]==1 then
			-- 中断当前效果处理，使后续效果视为错时点处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=spg:Select(tp,1,1,nil)
			-- 将选中的恶魔族怪兽特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
		if opval[op]==2 then
			-- 中断当前效果处理，使后续效果视为错时点处理
			Duel.BreakEffect()
			-- 提示玩家选择要盖放的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local sg=stg:Select(tp,1,1,nil)
			-- 将选中的卡盖放到场上
			Duel.SSet(tp,sg,tp,false)
		end
	end
end
