--極星宝フリドスキャルヴ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从卡组把1只「极星」怪兽特殊召唤。只要这个效果特殊召唤的怪兽表侧表示存在，自己不是「极神」怪兽不能从额外卡组特殊召唤。
-- ②：把墓地的这张卡除外才能发动。从卡组把1只「极星」怪兽加入手卡。那之后，选1张手卡回到卡组。
function c7320132.initial_effect(c)
	-- ①：从卡组把1只「极星」怪兽特殊召唤。只要这个效果特殊召唤的怪兽表侧表示存在，自己不是「极神」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7320132,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,7320132)
	e1:SetTarget(c7320132.sptg)
	e1:SetOperation(c7320132.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从卡组把1只「极星」怪兽加入手卡。那之后，选1张手卡回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7320132,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,7320132)
	-- 把墓地的这张卡除外作为发动成本
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c7320132.thtg)
	e2:SetOperation(c7320132.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡组中可以特殊召唤的「极星」怪兽
function c7320132.spfilter(c,e,tp)
	return c:IsSetCard(0x42) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备（检查怪兽区域空位及卡组中是否存在可特召的「极星」怪兽，并设置操作信息）
function c7320132.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足特召条件的「极星」怪兽
		and Duel.IsExistingMatchingCard(c7320132.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理（从卡组特殊召唤「极星」怪兽，并对其添加额外卡组特召限制）
function c7320132.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时怪兽区域已无空格，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足条件的「极星」怪兽
	local tc=Duel.SelectMatchingCard(tp,c7320132.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc then
		-- 将选中的怪兽以表侧表示特殊召唤（分步处理）
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 只要这个效果特殊召唤的怪兽表侧表示存在，自己不是「极神」怪兽不能从额外卡组特殊召唤。②：把墓地的这张卡除外才能发动。从卡组把1只「极星」怪兽加入手卡。那之后，选1张手卡回到卡组。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(c7320132.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 完成特殊召唤的处理
		Duel.SpecialSummonComplete()
	end
end
-- 限制条件：不能从额外卡组特殊召唤「极神」以外的怪兽
function c7320132.splimit(e,c)
	return not c:IsSetCard(0x4b) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤条件：卡组中可以加入手牌的「极星」怪兽
function c7320132.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x42) and c:IsAbleToHand()
end
-- ②效果的发动准备（检查卡组中是否存在可检索的「极星」怪兽，并设置检索和回卡组的操作信息）
function c7320132.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只「极星」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c7320132.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：将1张手牌送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- ②效果的处理（从卡组将「极星」怪兽加入手牌，之后选择1张手牌送回卡组）
function c7320132.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只「极星」怪兽
	local g=Duel.SelectMatchingCard(tp,c7320132.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切手牌
		Duel.ShuffleHand(tp)
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 从手牌中选择1张可以送回卡组的卡
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if #sg>0 then
			-- 中断当前效果，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
			-- 将选中的手牌送回卡组并洗卡组
			Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
