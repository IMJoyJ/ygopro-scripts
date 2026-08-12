--神鳥の排撃
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡丢弃1只鸟兽族怪兽才能发动。对方的魔法与陷阱区域的卡全部回到持有者手卡。
-- ②：把墓地的这张卡除外才能发动。手卡1只鸟兽族怪兽给对方观看。这个回合，那只怪兽以及自己手卡的同名怪兽的等级下降1星。
function c64002884.initial_effect(c)
	-- ①：从手卡丢弃1只鸟兽族怪兽才能发动。对方的魔法与陷阱区域的卡全部回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64002884,0))  --"回到手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,64002884+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c64002884.cost)
	e1:SetTarget(c64002884.target)
	e1:SetOperation(c64002884.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。手卡1只鸟兽族怪兽给对方观看。这个回合，那只怪兽以及自己手卡的同名怪兽的等级下降1星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(64002884,1))  --"等级下降"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 把墓地的这张卡除外作为发动代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c64002884.lvtg)
	e2:SetOperation(c64002884.lvop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡中可以丢弃的鸟兽族怪兽
function c64002884.costfilter(c)
	return c:IsRace(RACE_WINDBEAST) and c:IsDiscardable()
end
-- ①号效果的发动代价：从手卡丢弃1只鸟兽族怪兽
function c64002884.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以丢弃的鸟兽族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c64002884.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1只满足条件的鸟兽族怪兽作为代价
	Duel.DiscardHand(tp,c64002884.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：对方魔法与陷阱区域（不含场地区）可以回到手卡的卡
function c64002884.thfilter(c)
	return c:GetSequence()<5 and c:IsAbleToHand()
end
-- ①号效果的发动准备：检查对方魔陷区是否有卡，并设置收集回手卡的操作信息
function c64002884.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方魔法与陷阱区域是否存在可以回到手卡的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c64002884.thfilter,tp,0,LOCATION_SZONE,1,nil) end
	-- 获取对方魔法与陷阱区域中所有可以回到手卡的卡片组
	local g=Duel.GetMatchingGroup(c64002884.thfilter,tp,0,LOCATION_SZONE,nil)
	-- 设置连锁处理的操作信息：将对方魔陷区的所有卡送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- ①号效果的处理：将对方魔法与陷阱区域的卡全部回到持有者手卡
function c64002884.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方魔法与陷阱区域中所有可以回到手卡的卡片组
	local g=Duel.GetMatchingGroup(c64002884.thfilter,tp,0,LOCATION_SZONE,nil)
	if g:GetCount()>0 then
		-- 将这些卡全部送回持有者的手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 过滤条件：手卡中等级2以上且未公开的鸟兽族怪兽
function c64002884.cffilter(c)
	return c:IsRace(RACE_WINDBEAST) and c:IsLevelAbove(2) and not c:IsPublic()
end
-- ②号效果的发动准备：检查手卡中是否存在可以给对方观看的鸟兽族怪兽
function c64002884.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在满足条件的鸟兽族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c64002884.cffilter,tp,LOCATION_HAND,0,1,nil) end
end
-- ②号效果的处理：让对方确认手卡中的1只鸟兽族怪兽，并使手卡中该怪兽及同名怪兽的等级下降1星
function c64002884.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家选择手卡中1只满足条件的鸟兽族怪兽
	local g=Duel.SelectMatchingCard(tp,c64002884.cffilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 给对方玩家确认选择的卡
	Duel.ConfirmCards(1-tp,g)
	-- 洗切玩家的手卡
	Duel.ShuffleHand(tp)
	-- 获取自己手卡中与被确认怪兽同名的所有卡片组
	local sg=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_HAND,0,nil,g:GetFirst():GetCode())
	local tc=sg:GetFirst()
	while tc do
		-- 这个回合，那只怪兽以及自己手卡的同名怪兽的等级下降1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=sg:GetNext()
	end
end
