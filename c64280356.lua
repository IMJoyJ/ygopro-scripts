--Kozmo－フェルブラン
-- 效果：
-- 「星际仙踪-铁皮」的①的效果1回合只能使用1次。
-- ①：把场上的这张卡除外才能发动。从手卡把1只2星以上的「星际仙踪」怪兽特殊召唤。这个效果在对方回合也能发动。
-- ②：自己·对方的结束阶段支付500基本分才能发动。从卡组把「星际仙踪」卡3种类给对方观看，对方从那之中随机选1张。那1张卡加入自己手卡，剩余送去墓地。
function c64280356.initial_effect(c)
	-- 「星际仙踪-铁皮」的①的效果1回合只能使用1次。①：把场上的这张卡除外才能发动。从手卡把1只2星以上的「星际仙踪」怪兽特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64280356,0))  --"从手卡把「星际仙踪」怪兽特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,64280356)
	e1:SetCost(c64280356.spcost)
	e1:SetTarget(c64280356.sptg)
	e1:SetOperation(c64280356.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的结束阶段支付500基本分才能发动。从卡组把「星际仙踪」卡3种类给对方观看，对方从那之中随机选1张。那1张卡加入自己手卡，剩余送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(64280356,1))  --"从卡组把「星际仙踪」卡加入手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCost(c64280356.thcost)
	e2:SetTarget(c64280356.thtg)
	e2:SetOperation(c64280356.thop)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价（Cost）函数：将场上的自身除外
function c64280356.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将场上的这张卡表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤函数：手卡中2星以上的「星际仙踪」怪兽
function c64280356.spfilter(c,e,tp)
	return c:IsSetCard(0xd2) and c:IsLevelAbove(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备（Target）函数
function c64280356.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域（因为自身作为Cost除外会空出一个格子，所以可用格子数大于-1即可）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 并且检查手卡中是否存在至少1只满足条件的「星际仙踪」怪兽
		and Duel.IsExistingMatchingCard(c64280356.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁信息：包含从手卡特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果的处理（Operation）函数
function c64280356.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的「星际仙踪」怪兽
	local g=Duel.SelectMatchingCard(tp,c64280356.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：卡组中可以加入手卡的「星际仙踪」卡片
function c64280356.thfilter(c)
	return c:IsSetCard(0xd2) and c:IsAbleToHand()
end
-- ②效果的发动代价（Cost）函数：支付500基本分
function c64280356.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 支付500基本分
	Duel.PayLPCost(tp,500)
end
-- ②效果的发动准备（Target）函数
function c64280356.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家是否能将卡组的卡送去墓地（防止因无法送墓而无法发动）
		if not Duel.IsPlayerCanDiscardDeck(tp,1) then return false end
		-- 获取卡组中所有满足条件的「星际仙踪」卡片
		local dg=Duel.GetMatchingGroup(c64280356.thfilter,tp,LOCATION_DECK,0,nil)
		return dg:GetClassCount(Card.GetCode)>=3
	end
	-- 设置连锁信息：包含从卡组将1张卡加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理（Operation）函数
function c64280356.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查玩家是否能将卡组的卡送去墓地，若不能则不处理
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 获取卡组中所有满足条件的「星际仙踪」卡片
	local g=Duel.GetMatchingGroup(c64280356.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)>=3 then
		-- 提示玩家选择要给对方确认的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 让玩家从卡组中选择3张卡名不同的「星际仙踪」卡片
		local sg1=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
		-- 给对方玩家确认选中的3张卡
		Duel.ConfirmCards(1-tp,sg1)
		-- 洗切自己的卡组
		Duel.ShuffleDeck(tp)
		-- 提示对方玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local cg=sg1:Select(1-tp,1,1,nil)
		local tc=cg:GetFirst()
		tc:SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 将对方随机选中的那1张卡加入自己手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		sg1:RemoveCard(tc)
		-- 将剩余的卡送去墓地
		Duel.SendtoGrave(sg1,REASON_EFFECT)
	end
end
