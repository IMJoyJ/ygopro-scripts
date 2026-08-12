--救いの架け橋
-- 效果：
-- 这个卡名的①②的效果在决斗中各能适用1次。
-- ①：场上的10星以上的怪兽的种族是2种类以上的场合才能发动。这张卡以外的双方的手卡·场上·墓地的卡全部回到持有者卡组。那之后，双方从卡组抽5张。
-- ②：把墓地的这张卡除外才能发动。从卡组把1只「宝玉兽」怪兽和1张场地魔法卡加入手卡。
function c5611760.initial_effect(c)
	-- 这个卡名的①的效果在决斗中各能适用1次。①：场上的10星以上的怪兽的种族是2种类以上的场合才能发动。这张卡以外的双方的手卡·场上·墓地的卡全部回到持有者卡组。那之后，双方从卡组抽5张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c5611760.condition)
	e1:SetTarget(c5611760.target)
	e1:SetOperation(c5611760.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果在决斗中各能适用1次。②：把墓地的这张卡除外才能发动。从卡组把1只「宝玉兽」怪兽和1张场地魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCondition(c5611760.thcon)
	-- 把墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c5611760.thtg)
	e2:SetOperation(c5611760.thop)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示且等级在10以上的怪兽
function c5611760.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(10)
end
-- 效果①的发动条件：决斗中未适用过该效果，且场上10星以上的怪兽种族在2种类以上
function c5611760.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有表侧表示且等级在10以上的怪兽
	local g=Duel.GetMatchingGroup(c5611760.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 检查当前玩家本局决斗中是否未适用过效果①，且上述怪兽的种族数量是否大于等于2
	return Duel.GetFlagEffect(tp,5611760)==0 and g:GetClassCount(Card.GetRace)>=2
end
-- 效果①的发动准备：设置操作信息为将双方手卡、场上、墓地的卡送回卡组
function c5611760.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方手卡、场上、墓地中除战斗破坏确定以外的所有卡片
	local g=Duel.GetMatchingGroup(aux.NOT(Card.IsStatus),tp,0x1e,0x1e,nil,STATUS_BATTLE_DESTROYED)
	-- 设置当前连锁的操作信息为将上述卡片全部送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0x1e)
end
-- 效果①的处理：将除这张卡以外的双方手卡、场上、墓地的卡全部回到持有者卡组，之后双方各抽5张
function c5611760.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查决斗中是否已适用过效果①，若已适用则直接返回
	if Duel.GetFlagEffect(tp,5611760)~=0 then return end
	-- 注册决斗中已适用效果①的全局标记
	Duel.RegisterFlagEffect(tp,5611760,0,0,0)
	local c=e:GetHandler()
	-- 获取双方手卡、场上、墓地中除这张卡本身及战斗破坏确定以外的所有卡片
	local g=Duel.GetMatchingGroup(aux.NOT(Card.IsStatus),tp,0x1e,0x1e,aux.ExceptThisCard(e),STATUS_BATTLE_DESTROYED)
	-- 检查上述卡片中是否包含受“王家长眠之谷”影响的墓地卡片，若有则无效此效果
	if aux.NecroValleyNegateCheck(g) then return end
	-- 将这些卡全部送回持有者卡组并洗牌，若没有卡片成功回到卡组则不处理后续效果
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
	-- 过滤出实际上成功回到卡组（不含额外卡组）的卡片组
	local tg=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_DECK)
	-- 如果回卡组的卡片中包含我方玩家的卡，则洗切我方卡组
	if tg:IsExists(Card.IsControler,1,nil,tp) then Duel.ShuffleDeck(tp) end
	-- 如果回卡组的卡片中包含对方玩家的卡，则洗切对方卡组
	if tg:IsExists(Card.IsControler,1,nil,1-tp) then Duel.ShuffleDeck(1-tp) end
	-- 中断当前效果，使后续的抽卡处理不与回卡组同时进行（造成错时点）
	Duel.BreakEffect()
	-- 我方玩家从卡组抽5张卡
	Duel.Draw(tp,5,REASON_EFFECT)
	-- 对方玩家从卡组抽5张卡
	Duel.Draw(1-tp,5,REASON_EFFECT)
end
-- 效果②的发动条件：决斗中未适用过该效果
function c5611760.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家本局决斗中是否未适用过效果②
	return Duel.GetFlagEffect(tp,5611761)==0
end
-- 过滤卡组中可以加入手牌的「宝玉兽」怪兽
function c5611760.thfilter1(c)
	return c:IsSetCard(0x1034) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 过滤卡组中可以加入手牌的场地魔法卡
function c5611760.thfilter2(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- 效果②的发动准备：检查卡组中是否存在可检索的「宝玉兽」怪兽和场地魔法卡，并设置检索2张卡的操作信息
function c5611760.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方卡组是否存在至少1只「宝玉兽」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c5611760.thfilter1,tp,LOCATION_DECK,0,1,nil)
		-- 并且检查我方卡组是否存在至少1张场地魔法卡
		and Duel.IsExistingMatchingCard(c5611760.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为从卡组将2张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 效果②的处理：从卡组选择1只「宝玉兽」怪兽和1张场地魔法卡加入手牌
function c5611760.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查决斗中是否已适用过效果②，若已适用则直接返回
	if Duel.GetFlagEffect(tp,5611761)~=0 then return end
	-- 注册决斗中已适用效果②的全局标记
	Duel.RegisterFlagEffect(tp,5611761,0,0,0)
	-- 获取我方卡组中所有的「宝玉兽」怪兽
	local g1=Duel.GetMatchingGroup(c5611760.thfilter1,tp,LOCATION_DECK,0,nil)
	-- 获取我方卡组中所有的场地魔法卡
	local g2=Duel.GetMatchingGroup(c5611760.thfilter2,tp,LOCATION_DECK,0,nil)
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 提示我方玩家选择要加入手牌的第一张卡（「宝玉兽」怪兽）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg1=g1:Select(tp,1,1,nil)
		-- 提示我方玩家选择要加入手牌的第二张卡（场地魔法卡）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg2=g2:Select(tp,1,1,nil)
		sg1:Merge(sg2)
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(sg1,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,sg1)
	end
end
