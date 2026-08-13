--雪花の光
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己墓地没有魔法·陷阱卡存在的场合才能发动。自己从卡组抽2张。这张卡的发动后，这次决斗中自己不能把「雪花之光」以外的魔法·陷阱卡的效果发动。
-- ②：把墓地的这张卡除外才能发动。把手卡1只怪兽给对方观看，回到卡组洗切。那之后，自己从卡组抽1张。
function c24940422.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己墓地没有魔法·陷阱卡存在的场合才能发动。自己从卡组抽2张。这张卡的发动后，这次决斗中自己不能把「雪花之光」以外的魔法·陷阱卡的效果发动。
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
	-- 设定将墓地的这张卡除外作为效果发动代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c24940422.tdtg)
	e2:SetOperation(c24940422.tdop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：自己的墓地没有魔法·陷阱卡存在。
function c24940422.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在魔法·陷阱卡，不存在时返回真，即满足①效果发动条件。
	return not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
-- ①效果发动时进行合法判定，并设定目标玩家为自己、抽卡数为2，同时登记抽2张卡的操作信息。
function c24940422.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：当前玩家是否可以抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将抽卡对象玩家设定为当前玩家。
	Duel.SetTargetPlayer(tp)
	-- 设定抽卡数量参数为2。
	Duel.SetTargetParam(2)
	-- 登记操作信息：该效果将让目标玩家抽2张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- ①效果处理：自己抽2张；若这张卡是以魔法卡发动的方式发动，则给自己附加本决斗中不能发动「雪花之光」以外的魔法·陷阱卡效果的制约。
function c24940422.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中取出之前设定的目标玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家抽2张卡（效果抽卡）。
	Duel.Draw(p,d,REASON_EFFECT)
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，这次决斗中自己不能把「雪花之光」以外的魔法·陷阱卡的效果发动。②：把墓地的这张卡除外才能发动。把手卡1只怪兽给对方观看，回到卡组洗切。那之后，自己从卡组抽1张。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(24940422,2))  --"「雪花之光」效果适用中"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c24940422.aclimit)
	-- 将自肃效果注册给当前玩家，使其开始适用。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃判定：若发动效果的卡不是「雪花之光」且该效果是魔法·陷阱卡效果，则禁止发动。
function c24940422.aclimit(e,re,tp)
	return not re:GetHandler():IsCode(24940422) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 可作为②效果返回卡组对象的手牌怪兽需满足：是怪兽且可以返回卡组。
function c24940422.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- ②效果发动时，确认自己可以抽1张且手牌存在可返回卡组的怪兽，然后设定目标玩家为自己，登记返回卡组与抽卡的操作信息。
function c24940422.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果合法性检查：当前玩家是否可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 并检查手牌是否存在至少1张符合可返回卡组条件的怪兽；若可抽牌且怪兽存在，则②效果可发动。
		and Duel.IsExistingMatchingCard(c24940422.tdfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 将②效果的对象玩家设定为当前玩家。
	Duel.SetTargetPlayer(tp)
	-- 登记操作信息：从手牌选1张卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	-- 登记操作信息：目标玩家抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：若手牌存在符合条件的怪兽，则选择1只给对方确认，放回卡组洗切，然后自己抽1张卡。
function c24940422.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出当前连锁设定的目标玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取目标玩家手牌中所有满足可返回卡组条件的怪兽卡。
	local g=Duel.GetMatchingGroup(c24940422.tdfilter,p,LOCATION_HAND,0,nil)
	if g:GetCount()>0 then
		-- 显示选择提示，要求玩家选择要返回卡组的卡。
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=g:Select(p,1,1,nil)
		-- 将选中的手牌怪兽展示给对方玩家确认。
		Duel.ConfirmCards(1-p,sg)
		-- 将选择的卡返回持有者的卡组，并标记为需要洗切的位置。
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 洗切目标玩家的卡组。
		Duel.ShuffleDeck(p)
		-- 中断当前效果处理，使后续抽卡作为不同时点处理，避免错过时点。
		Duel.BreakEffect()
		-- 让目标玩家抽1张卡。
		Duel.Draw(p,1,REASON_EFFECT)
	end
end
