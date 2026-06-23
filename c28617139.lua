--神鳥の来寇
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡丢弃1只鸟兽族怪兽才能发动。从卡组把2只「斯摩夫」怪兽加入手卡（相同属性最多1只）。
-- ②：把墓地的这张卡除外才能发动。手卡1只鸟兽族怪兽给对方观看。这个回合，那只怪兽以及自己手卡的同名怪兽的等级下降1星。
function c28617139.initial_effect(c)
	-- ①：从手卡丢弃1只鸟兽族怪兽才能发动。从卡组把2只「斯摩夫」怪兽加入手卡（相同属性最多1只）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28617139,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,28617139+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c28617139.cost)
	e1:SetTarget(c28617139.target)
	e1:SetOperation(c28617139.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。手卡1只鸟兽族怪兽给对方观看。这个回合，那只怪兽以及自己手卡的同名怪兽的等级下降1星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28617139,1))  --"等级下降"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 将墓地的这张卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c28617139.lvtg)
	e2:SetOperation(c28617139.lvop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡中是否存在1只鸟兽族且可丢弃的怪兽
function c28617139.costfilter(c)
	return c:IsRace(RACE_WINDBEAST) and c:IsDiscardable()
end
-- 效果发动时的处理函数，检查手卡是否存在满足条件的怪兽并将其丢弃
function c28617139.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1只鸟兽族且可丢弃的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c28617139.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手卡丢弃1只满足条件的鸟兽族怪兽
	Duel.DiscardHand(tp,c28617139.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，用于判断卡组中是否存在1只「斯摩夫」怪兽
function c28617139.thfilter(c)
	return c:IsSetCard(0x12d) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动时的处理函数，检查卡组中是否存在至少2个不同属性的「斯摩夫」怪兽
function c28617139.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组中所有满足条件的「斯摩夫」怪兽
	local g=Duel.GetMatchingGroup(c28617139.thfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetAttribute)>=2 end
	-- 设置连锁操作信息，表示将从卡组检索2张「斯摩夫」怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 效果发动时的处理函数，检索满足条件的2张「斯摩夫」怪兽并确认给对方观看
function c28617139.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足条件的「斯摩夫」怪兽
	local g=Duel.GetMatchingGroup(c28617139.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetAttribute)<2 then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从满足条件的怪兽中选择2张属性不同的怪兽
	local sg=g:SelectSubGroup(tp,aux.dabcheck,false,2,2)
	-- 将选中的怪兽加入手牌
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
	-- 向对方确认所选的怪兽
	Duel.ConfirmCards(1-tp,sg)
end
-- 过滤函数，用于判断手卡中是否存在1只鸟兽族且等级不低于2且未公开的怪兽
function c28617139.cffilter(c)
	return c:IsRace(RACE_WINDBEAST) and c:IsLevelAbove(2) and not c:IsPublic()
end
-- 效果发动时的处理函数，检查手卡中是否存在满足条件的怪兽
function c28617139.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1只鸟兽族且等级不低于2且未公开的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c28617139.cffilter,tp,LOCATION_HAND,0,1,nil) end
end
-- 效果发动时的处理函数，选择1只鸟兽族怪兽给对方确认并降低其等级
function c28617139.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要给对方确认的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择1只满足条件的鸟兽族怪兽
	local g=Duel.SelectMatchingCard(tp,c28617139.cffilter,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		-- 向对方确认所选的怪兽
		Duel.ConfirmCards(1-tp,g)
		-- 将玩家手牌洗切
		Duel.ShuffleHand(tp)
		-- 获取与所选怪兽同名的所有手牌怪兽
		local sg=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_HAND,0,nil,g:GetFirst():GetCode())
		local tc=sg:GetFirst()
		while tc do
			-- 为所选怪兽及其同名怪兽设置等级下降1星的效果
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetValue(-1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			tc=sg:GetNext()
		end
	end
end
