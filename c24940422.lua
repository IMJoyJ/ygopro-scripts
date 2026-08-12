--雪花の光
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己墓地没有魔法·陷阱卡存在的场合才能发动。自己从卡组抽2张。这张卡的发动后，这次决斗中自己不能把「雪花之光」以外的魔法·陷阱卡的效果发动。
-- ②：把墓地的这张卡除外才能发动。把手卡1只怪兽给对方观看，回到卡组洗切。那之后，自己从卡组抽1张。
function c24940422.initial_effect(c)
	-- ①：自己墓地没有魔法·陷阱卡存在的场合才能发动。自己从卡组抽2张。这张卡的发动后，这次决斗中自己不能把「雪花之光」以外的魔法·陷阱卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24940422,0))  --"发动"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,24940422)
	e1:SetCondition(c24940422.condition)
	e1:SetTarget(c24940422.target)
	e1:SetOperation(c24940422.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。把手卡1只怪兽给对方观看，回到卡组洗切。那之后，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24940422,1))  --"回到卡组并抽卡"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,24940423)
	-- 将此卡从墓地除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c24940422.tdtg)
	e2:SetOperation(c24940422.tdop)
	c:RegisterEffect(e2)
end
-- 检查自己墓地是否存在魔法·陷阱卡
function c24940422.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己墓地没有魔法·陷阱卡则满足条件
	return not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
-- 设置效果目标为自身玩家，设置效果参数为2，设置操作信息为抽2张卡
function c24940422.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置效果目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果目标参数为2
	Duel.SetTargetParam(2)
	-- 设置操作信息为抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 发动效果时执行的操作：抽2张卡并设置不能发动魔法·陷阱卡的效果
function c24940422.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 创建一个影响全场玩家的永续效果，禁止发动魔法·陷阱卡
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(24940422,2))  --"「雪花之光」的效果适用中"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c24940422.aclimit)
	-- 将效果注册给当前玩家
	Duel.RegisterEffect(e1,tp)
end
-- 判断是否为非「雪花之光」的魔法·陷阱卡效果
function c24940422.aclimit(e,re,tp)
	return not re:GetHandler():IsCode(24940422) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 过滤函数：检查手卡中是否为怪兽且能送回卡组
function c24940422.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 设置效果目标为自身玩家，设置操作信息为送1只怪兽回卡组和抽1张卡
function c24940422.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查手卡中是否存在至少1只怪兽
		and Duel.IsExistingMatchingCard(c24940422.tdfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 设置效果目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置操作信息为送1只怪兽回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息为抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 处理效果：选择手卡怪兽送回卡组并抽1张卡
function c24940422.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c24940422.tdfilter,p,LOCATION_HAND,0,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要送回卡组的怪兽
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=g:Select(p,1,1,nil)
		-- 向对方确认选择的怪兽
		Duel.ConfirmCards(1-p,sg)
		-- 将选择的怪兽送回卡组并洗切
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 洗切玩家的卡组
		Duel.ShuffleDeck(p)
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 让目标玩家抽1张卡
		Duel.Draw(p,1,REASON_EFFECT)
	end
end
