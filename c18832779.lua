--海造賊－双翼のリュース号
-- 效果：
-- 「海造贼」怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段才能发动。从手卡以及自己的魔法与陷阱区域的表侧表示的卡之中选1张「海造贼」怪兽卡特殊召唤。
-- ②：对方把怪兽的效果发动时，从手卡丢弃1张「海造贼」卡才能发动。那个发动无效并破坏。这张卡有「海造贼」卡装备的场合，可以再从卡组把1张「海造贼」卡加入手卡。
function c18832779.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，使用2个满足「海造贼」融合条件的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x13f),2,true)
	-- ①：自己·对方的主要阶段才能发动。从手卡以及自己的魔法与陷阱区域的表侧表示的卡之中选1张「海造贼」怪兽卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18832779,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,18832779)
	e1:SetCondition(c18832779.spcon)
	e1:SetTarget(c18832779.sptg)
	e1:SetOperation(c18832779.spop)
	c:RegisterEffect(e1)
	-- ②：对方把怪兽的效果发动时，从手卡丢弃1张「海造贼」卡才能发动。那个发动无效并破坏。这张卡有「海造贼」卡装备的场合，可以再从卡组把1张「海造贼」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18832779,1))  --"发动无效"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,18832780)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(c18832779.discon)
	e2:SetCost(c18832779.discost)
	e2:SetTarget(c18832779.distg)
	e2:SetOperation(c18832779.disop)
	c:RegisterEffect(e2)
end
-- 效果发动条件：当前阶段为自己的主要阶段1或主要阶段2
function c18832779.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为自己的主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 特殊召唤的过滤条件：满足「海造贼」种族、在手卡或场上表侧表示、可以特殊召唤
function c18832779.spfilter(c,e,tp)
	return c:IsSetCard(0x13f) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动条件：场上存在满足条件的「海造贼」怪兽卡且有空位
function c18832779.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或魔法与陷阱区域是否存在满足条件的「海造贼」怪兽卡
		and Duel.IsExistingMatchingCard(c18832779.spfilter,tp,LOCATION_SZONE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE+LOCATION_HAND)
end
-- 特殊召唤效果的处理：选择并特殊召唤满足条件的卡
function c18832779.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「海造贼」怪兽卡
	local g=Duel.SelectMatchingCard(tp,c18832779.spfilter,tp,LOCATION_SZONE+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 无效效果发动的条件：该卡未因战斗破坏、对方发动、发动的怪兽效果可被无效
function c18832779.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp
		-- 对方发动的怪兽效果可被无效
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 丢弃卡的过滤条件：可丢弃且为「海造贼」种族
function c18832779.discfilter(c)
	return c:IsDiscardable() and c:IsSetCard(0x13f)
end
-- 无效效果发动的消耗：丢弃1张「海造贼」卡
function c18832779.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在满足条件的「海造贼」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c18832779.discfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃1张「海造贼」卡
	Duel.DiscardHand(tp,c18832779.discfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 无效效果发动的目标设定：设置无效和破坏的操作信息
function c18832779.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置无效效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 装备卡的过滤条件：装备卡为「海造贼」种族且表侧表示
function c18832779.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x13f)
end
-- 检索卡的过滤条件：为「海造贼」种族且可加入手牌
function c18832779.thfilter(c)
	return c:IsSetCard(0x13f) and c:IsAbleToHand()
end
-- 无效效果发动的处理：无效对方发动、破坏对方怪兽、若装备有「海造贼」卡则检索1张加入手牌
function c18832779.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 使对方发动无效
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re)
		-- 破坏对方怪兽
		and Duel.Destroy(eg,REASON_EFFECT)>0 and c:IsRelateToEffect(e)
		and c:GetEquipGroup():IsExists(c18832779.eqfilter,1,nil)
		-- 检查卡组是否存在满足条件的「海造贼」卡
		and Duel.IsExistingMatchingCard(c18832779.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否从卡组检索1张「海造贼」卡
		and Duel.SelectYesNo(tp,aux.Stringid(18832779,2)) then  --"是否从卡组把「海造贼」卡加入手卡？"
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择满足条件的「海造贼」卡
		local g=Duel.SelectMatchingCard(tp,c18832779.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
