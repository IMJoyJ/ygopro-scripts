--救いの架け橋
-- 效果：
-- 这个卡名的①②的效果在决斗中各能适用1次。
-- ①：场上的10星以上的怪兽的种族是2种类以上的场合才能发动。这张卡以外的双方的手卡·场上·墓地的卡全部回到持有者卡组。那之后，双方从卡组抽5张。
-- ②：把墓地的这张卡除外才能发动。从卡组把1只「宝玉兽」怪兽和1张场地魔法卡加入手卡。
function c5611760.initial_effect(c)
	-- ①：场上的10星以上的怪兽的种族是2种类以上的场合才能发动。这张卡以外的双方的手卡·场上·墓地的卡全部回到持有者卡组。那之后，双方从卡组抽5张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c5611760.condition)
	e1:SetTarget(c5611760.target)
	e1:SetOperation(c5611760.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从卡组把1只「宝玉兽」怪兽和1张场地魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCondition(c5611760.thcon)
	-- 效果发动代价：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c5611760.thtg)
	e2:SetOperation(c5611760.thop)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示且等级10以上的怪兽
function c5611760.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(10)
end
-- 效果①的发动条件判定：确认本效果未适用过且场上10星以上怪兽种族在2种以上
function c5611760.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有表侧表示且等级10以上的怪兽
	local g=Duel.GetMatchingGroup(c5611760.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 检查决斗中未适用过该效果且满足种族数在2种以上
	return Duel.GetFlagEffect(tp,5611760)==0 and g:GetClassCount(Card.GetRace)>=2
end
-- 效果①的目标判定及操作信息设置
function c5611760.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方玩家是否均能因效果抽5张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,5) and Duel.IsPlayerCanDraw(1-tp,5) end
	-- 获取双方手卡·场上·墓地中除战斗破坏状态以外的所有卡片
	local g=Duel.GetMatchingGroup(aux.NOT(Card.IsStatus),tp,0x1e,0x1e,nil,STATUS_BATTLE_DESTROYED)
	-- 设置操作信息：将双方手卡·场上·墓地的卡全部回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0x1e)
	-- 设置操作信息：双方各抽5张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,5)
end
-- 效果处理：除此卡外双方手卡·场上·墓地卡片洗回卡组，之后双方各抽5张
function c5611760.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查该效果在决斗中是否已适用
	if Duel.GetFlagEffect(tp,5611760)~=0 then return end
	-- 注册决斗中适用的标记
	Duel.RegisterFlagEffect(tp,5611760,0,0,0)
	local c=e:GetHandler()
	-- 获取除本卡外双方手卡·场上·墓地中所有未处于战斗破坏状态的卡
	local g=Duel.GetMatchingGroup(aux.NOT(Card.IsStatus),tp,0x1e,0x1e,aux.ExceptThisCard(e),STATUS_BATTLE_DESTROYED)
	-- 检查是否被王家长眠之谷无效
	if aux.NecroValleyNegateCheck(g) then return end
	-- 将卡片送回卡组并洗牌，若无卡回到卡组则终止后续处理
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
	-- 筛选实际返回主卡组的卡片组
	local tg=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_DECK)
	-- 若有卡回到自身卡组则洗牌
	if tg:IsExists(Card.IsControler,1,nil,tp) then Duel.ShuffleDeck(tp) end
	-- 若有卡回到对方卡组则洗牌
	if tg:IsExists(Card.IsControler,1,nil,1-tp) then Duel.ShuffleDeck(1-tp) end
	-- 分隔前后效果处理时点
	Duel.BreakEffect()
	-- 自身抽5张卡
	Duel.Draw(tp,5,REASON_EFFECT)
	-- 对方抽5张卡
	Duel.Draw(1-tp,5,REASON_EFFECT)
end
-- 效果②的发动条件判定
function c5611760.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查效果②在决斗中是否未适用
	return Duel.GetFlagEffect(tp,5611761)==0
end
-- 过滤卡组中可加入手牌的「宝玉兽」怪兽
function c5611760.thfilter1(c)
	return c:IsSetCard(0x1034) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 过滤卡组中可加入手牌的场地魔法卡
function c5611760.thfilter2(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- 检索效果的目标判定及操作信息设置
function c5611760.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在「宝玉兽」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c5611760.thfilter1,tp,LOCATION_DECK,0,1,nil)
		-- 检查卡组是否存在场地魔法卡
		and Duel.IsExistingMatchingCard(c5611760.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组把2张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：从卡组把1只「宝玉兽」怪兽和1张场地魔法卡加入手卡
function c5611760.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查该效果在决斗中是否未适用
	if Duel.GetFlagEffect(tp,5611761)~=0 then return end
	-- 注册效果②决斗中已适用的标记
	Duel.RegisterFlagEffect(tp,5611761,0,0,0)
	-- 获取卡组中所有「宝玉兽」怪兽
	local g1=Duel.GetMatchingGroup(c5611760.thfilter1,tp,LOCATION_DECK,0,nil)
	-- 获取卡组中所有场地魔法卡
	local g2=Duel.GetMatchingGroup(c5611760.thfilter2,tp,LOCATION_DECK,0,nil)
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 提示选择要加入手牌的「宝玉兽」怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg1=g1:Select(tp,1,1,nil)
		-- 提示选择要加入手牌的场地魔法卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg2=g2:Select(tp,1,1,nil)
		sg1:Merge(sg2)
		-- 将选中的2张卡加入手卡
		Duel.SendtoHand(sg1,nil,REASON_EFFECT)
		-- 向对方展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,sg1)
	end
end
