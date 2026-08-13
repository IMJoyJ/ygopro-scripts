--海造賊－双翼のリュース号
-- 效果：
-- 「海造贼」怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段才能发动。从手卡以及自己的魔法与陷阱区域的表侧表示的卡之中选1张「海造贼」怪兽卡特殊召唤。
-- ②：对方把怪兽的效果发动时，从手卡丢弃1张「海造贼」卡才能发动。那个发动无效并破坏。这张卡有「海造贼」卡装备的场合，可以再从卡组把1张「海造贼」卡加入手卡。
function c18832779.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以2只满足条件「海造贼」字段的怪兽作为融合素材（即「海造贼」怪兽×2）
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
-- ①效果的发动条件判断函数：判定当前阶段是否为主要阶段1或主要阶段2，以实现‘自己·对方的主要阶段才能发动’的条件。
function c18832779.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体条件：当前阶段是主要阶段1（PHASE_MAIN1）或主要阶段2（PHASE_MAIN2）时，满足发动时机。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- ①效果的特殊召唤对象过滤函数：筛选出持有者为自己、属于「海造贼」字段、位于手牌或场上表侧表示（涵盖手卡与魔陷区表侧表示的卡），且可以被特殊召唤的怪兽卡。
function c18832779.spfilter(c,e,tp)
	return c:IsSetCard(0x13f) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果发动时的目标选择函数：在发动确认（chk==0）时，检查自己场上是否有可用的怪兽区，以及是否存在满足条件（spfilter）的「海造贼」怪兽卡。
function c18832779.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区（LOCATION_MZONE），保证特殊召唤有可用区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在至少1张符合条件的「海造贼」怪兽卡（位于手牌或自己魔陷区表侧表示，且可特殊召唤）。
		and Duel.IsExistingMatchingCard(c18832779.spfilter,tp,LOCATION_SZONE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：宣告本效果包含特殊召唤（CATEGORY_SPECIAL_SUMMON），预计特殊召唤1张来自自己手牌或魔陷区的卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE+LOCATION_HAND)
end
-- ①效果处理执行函数：若有空余怪兽区，则从手牌和自己魔陷区表侧表示的卡中选择1张「海造贼」怪兽卡，将其表侧表示特殊召唤到自己场上。
function c18832779.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理开始时再次确认空余怪兽区数量；若没有空位，则不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向发动玩家显示选择提示：“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让发动玩家从自己的手牌和魔陷区中，选择1张符合条件的「海造贼」怪兽卡作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c18832779.spfilter,tp,LOCATION_SZONE+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的怪兽区域。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件判断函数：本卡未被战斗破坏、对方发动怪兽效果且该连锁可以被无效时才满足‘对方把怪兽的效果发动时’的条件。
function c18832779.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp
		-- 进一步确认：连锁的发动者是对方（由外层rp==1-tp判断），且该效果是怪兽效果（TYPE_MONSTER），并且该连锁发动可以被无效（Duel.IsChainNegatable）。
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- ②效果的cost过滤函数：用于选择从手卡丢弃的卡，要求该卡可以丢弃且属于「海造贼」字段。
function c18832779.discfilter(c)
	return c:IsDiscardable() and c:IsSetCard(0x13f)
end
-- ②效果的cost函数：发动时从手卡丢弃1张「海造贼」卡作为代价。
function c18832779.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查cost是否满足：手卡中是否存在至少1张符合discfilter条件（可丢弃的「海造贼」卡）。
	if chk==0 then return Duel.IsExistingMatchingCard(c18832779.discfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际执行cost：从手卡丢弃1张符合条件的「海造贼」卡，丢弃原因标记为cost。
	Duel.DiscardHand(tp,c18832779.discfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- ②效果的目标设定函数：将对方发动的那个怪兽效果（eg）设为无效及破坏的对象；不取对象，因此仅设置操作信息。
function c18832779.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：宣告要无效的是当前连锁（eg）的发动。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若该效果怪兽可被破坏且仍与那个效果关联，则额外设置操作信息：宣告要破坏该怪兽卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 用于检查本卡装备区是否存在表侧表示的「海造贼」卡的过滤函数。
function c18832779.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x13f)
end
-- 用于检索卡组中可加入手卡的「海造贼」卡的过滤函数。
function c18832779.thfilter(c)
	return c:IsSetCard(0x13f) and c:IsAbleToHand()
end
-- ②效果处理执行函数：先无效并破坏对方发动的怪兽效果及其卡片；若此时本卡仍有效、装备有「海造贼」卡、且卡组中有可检索的「海造贼」卡，则询问玩家是否再从卡组将1张「海造贼」卡加入手卡。
function c18832779.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 无效对方怪兽效果的发动，并确认该效果怪兽仍然与那个效果关联（未被中途除外或离场）。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re)
		-- 将该怪兽卡破坏，并确认本卡（e:GetHandler()）仍然与当前效果关联（仍在场上且效果有效）。
		and Duel.Destroy(eg,REASON_EFFECT)>0 and c:IsRelateToEffect(e)
		and c:GetEquipGroup():IsExists(c18832779.eqfilter,1,nil)
		-- 检查卡组中是否存在至少1张可加入手卡的「海造贼」卡，作为追加检索的前提。
		and Duel.IsExistingMatchingCard(c18832779.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否从卡组把1张「海造贼」卡加入手卡（对应“可以再从卡组把1张「海造贼」卡加入手卡”的选择）。
		and Duel.SelectYesNo(tp,aux.Stringid(18832779,2)) then  --"是否从卡组把「海造贼」卡加入手卡？"
		-- 中断当前效果处理，使后续的检索处理视为不同时处理（错开时点），避免与之前的无效破坏作为同一组效果处理。
		Duel.BreakEffect()
		-- 向玩家显示提示：“请选择要加入手牌的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1张符合条件的「海造贼」卡。
		local g=Duel.SelectMatchingCard(tp,c18832779.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 将选择的「海造贼」卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认本次加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
