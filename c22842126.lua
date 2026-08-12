--汎神の帝王
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：从手卡把1张「帝王」魔法·陷阱卡送去墓地才能发动。自己抽2张。
-- ②：把墓地的这张卡除外才能发动。从卡组把3张「帝王」魔法·陷阱卡给对方观看，对方从那之中选1张。那1张卡加入自己手卡，剩余回到卡组。
function c22842126.initial_effect(c)
	-- ①：从手卡把1张「帝王」魔法·陷阱卡送去墓地才能发动。自己抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22842126,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCost(c22842126.cost)
	e1:SetTarget(c22842126.target)
	e1:SetOperation(c22842126.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从卡组把3张「帝王」魔法·陷阱卡给对方观看，对方从那之中选1张。那1张卡加入自己手卡，剩余回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22842126,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,22842126)
	-- 效果发动时支付除外的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c22842126.thtg)
	e2:SetOperation(c22842126.thop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中满足条件的「帝王」魔法·陷阱卡
function c22842126.cfilter(c)
	return c:IsSetCard(0xbe) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 将满足条件的1张手卡送去墓地作为效果的代价
function c22842126.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足将1张「帝王」魔法·陷阱卡送去墓地的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c22842126.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行将1张「帝王」魔法·陷阱卡丢入墓地的操作
	Duel.DiscardHand(tp,c22842126.cfilter,1,1,REASON_COST,nil)
end
-- 设置效果的发动目标为自身并设定抽卡数量
function c22842126.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为抽2张卡
	Duel.SetTargetParam(2)
	-- 设置效果处理信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 执行效果的处理，使玩家抽卡
function c22842126.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 过滤卡组中满足条件的「帝王」魔法·陷阱卡
function c22842126.thfilter(c)
	return c:IsSetCard(0xbe) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置效果的发动目标为从卡组检索并选择1张卡加入手牌
function c22842126.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少3张「帝王」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c22842126.thfilter,tp,LOCATION_DECK,0,3,nil) end
	-- 设置效果处理信息为从卡组检索并选择1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行效果的处理，从卡组检索并选择1张卡加入手牌
function c22842126.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足条件的「帝王」魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c22842126.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,3,3,nil)
		-- 向对方确认所选的3张卡
		Duel.ConfirmCards(1-tp,sg)
		-- 提示对方选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tg=sg:Select(1-tp,1,1,nil)
		tg:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 将对方选择的卡加入手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
