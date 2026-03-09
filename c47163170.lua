--鉄獣戦線 塊撃のベアブルム
-- 效果：
-- 「铁兽」怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：丢弃2张手卡，以自己的除外状态的1只4星以下的兽族·兽战士族·鸟兽族怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：这张卡被送去墓地的场合才能发动。从卡组把1张「铁兽」魔法·陷阱卡加入手卡。那之后，选1张自己的手卡回到卡组最下面。这个效果的发动后，直到回合结束时自己不是「铁兽」怪兽不能特殊召唤。
function c47163170.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，需要2只满足「铁兽」系列的怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x14d),2,2)
	-- ①：丢弃2张手卡，以自己的除外状态的1只4星以下的兽族·兽战士族·鸟兽族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47163170,0))
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,47163170)
	e1:SetCost(c47163170.spcost)
	e1:SetTarget(c47163170.sptg)
	e1:SetOperation(c47163170.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合才能发动。从卡组把1张「铁兽」魔法·陷阱卡加入手卡。那之后，选1张自己的手卡回到卡组最下面。这个效果的发动后，直到回合结束时自己不是「铁兽」怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47163170,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,47163171)
	e2:SetTarget(c47163170.thtg)
	e2:SetOperation(c47163170.thop)
	c:RegisterEffect(e2)
end
-- 支付效果代价，丢弃2张手卡
function c47163170.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃2张手卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,2,nil) end
	-- 执行丢弃2张手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,2,2,REASON_COST+REASON_DISCARD)
end
-- 定义特殊召唤目标的过滤函数，筛选除外状态且等级不超过4的兽族·兽战士族·鸟兽族怪兽
function c47163170.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的目标选择逻辑，检查是否存在满足条件的除外怪兽
function c47163170.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and c47163170.spfilter(chkc,e,tp) end
	-- 检查场上是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足条件的除外怪兽作为目标
		and Duel.IsExistingTarget(c47163170.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的除外怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c47163170.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置效果处理信息，标明将特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作
function c47163170.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义检索卡组中「铁兽」魔法·陷阱卡的过滤函数
function c47163170.thfilter(c)
	return c:IsSetCard(0x14d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置检索并返回手卡和卡组的处理信息
function c47163170.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「铁兽」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c47163170.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将一张卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置将一张手卡送回卡组最底端的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 执行检索并返回手卡和卡组的操作
function c47163170.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张满足条件的「铁兽」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c47163170.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 判断是否成功将卡加入手牌并进行后续处理
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		-- 确认对方查看所选的卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切玩家的卡组
		Duel.ShuffleDeck(tp)
		-- 洗切玩家的手卡
		Duel.ShuffleHand(tp)
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 从手卡中选择一张卡送回卡组最底端
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if sg:GetCount()>0 then
			-- 中断当前效果处理，使后续效果视为错时点
			Duel.BreakEffect()
			-- 将选中的手卡送回卡组最底端
			Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
	-- 设置一个场上的效果，使自己不能特殊召唤非「铁兽」怪兽直到回合结束
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c47163170.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该限制特殊召唤的效果给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 定义限制特殊召唤的过滤函数，禁止召唤非「铁兽」怪兽
function c47163170.splimit(e,c)
	return not c:IsSetCard(0x14d)
end
