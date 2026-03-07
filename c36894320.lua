--無限械アイン・ソフ
-- 效果：
-- 把自己的魔法与陷阱区域1张表侧表示的「虚无械」送去墓地才能把这张卡发动。
-- ①：这张卡1回合只有1次不会被对方的效果破坏。
-- ②：1回合1次，可以从以下效果选择1个发动。
-- ●自己·对方的主要阶段才能发动。从手卡把1只「时械神」怪兽特殊召唤。
-- ●以自己墓地1只「时械神」怪兽为对象才能发动。那只怪兽回到卡组。那之后，可以从手卡·卡组选1张「无限光」在自己的魔法与陷阱区域盖放。
function c36894320.initial_effect(c)
	-- 效果原文：把自己的魔法与陷阱区域1张表侧表示的「虚无械」送去墓地才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c36894320.actcost)
	e1:SetTarget(c36894320.acttg)
	c:RegisterEffect(e1)
	-- 效果原文：①：这张卡1回合只有1次不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetCountLimit(1)
	e2:SetValue(c36894320.valcon)
	c:RegisterEffect(e2)
	-- 效果原文：②：1回合1次，可以从以下效果选择1个发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(36894320,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c36894320.spcon)
	e3:SetCost(c36894320.cost)
	e3:SetTarget(c36894320.sptg)
	e3:SetOperation(c36894320.spop)
	c:RegisterEffect(e3)
	-- 效果原文：●自己·对方的主要阶段才能发动。从手卡把1只「时械神」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(36894320,1))  --"墓地回收"
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_SSET)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCost(c36894320.cost)
	e4:SetTarget(c36894320.tdtg)
	e4:SetOperation(c36894320.tdop)
	c:RegisterEffect(e4)
end
-- 规则层面：使该效果在受到对方效果破坏时不会被破坏。
function c36894320.valcon(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and rp==1-e:GetHandlerPlayer()
end
-- 规则层面：过滤满足条件的「虚无械」卡（表侧表示且能送入墓地）。
function c36894320.acfilter(c)
	return c:IsFaceup() and c:IsCode(9409625) and c:IsAbleToGraveAsCost()
end
-- 规则层面：发动时将自己魔法与陷阱区域的1张「虚无械」送入墓地作为费用。
function c36894320.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查自己魔法与陷阱区域是否存在1张「虚无械」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c36894320.acfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 规则层面：提示玩家选择要送入墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 规则层面：选择满足条件的1张「虚无械」卡。
	local g=Duel.SelectMatchingCard(tp,c36894320.acfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 规则层面：将选中的卡送入墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 规则层面：设置发动时的处理逻辑，允许玩家选择发动效果。
function c36894320.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return c36894320.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
	if chk==0 then return true end
	local b1=c36894320.spcon(e,tp,eg,ep,ev,re,r,rp)
		and c36894320.cost(e,tp,eg,ep,ev,re,r,rp,0)
		and c36894320.sptg(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=c36894320.cost(e,tp,eg,ep,ev,re,r,rp,0)
		and c36894320.tdtg(e,tp,eg,ep,ev,re,r,rp,0)
	local op=-1
	-- 规则层面：判断是否可以发动效果并询问玩家选择。
	if (b1 or b2) and Duel.SelectYesNo(tp,94) then
		if b1 and b2 then
			-- 规则层面：选择“特殊召唤”效果。
			op=Duel.SelectOption(tp,aux.Stringid(36894320,0),aux.Stringid(36894320,1))  --"特殊召唤/墓地回收"
		elseif b1 then
			-- 规则层面：选择“特殊召唤”效果。
			op=Duel.SelectOption(tp,aux.Stringid(36894320,0))  --"特殊召唤"
		else
			-- 规则层面：选择“墓地回收”效果。
			op=Duel.SelectOption(tp,aux.Stringid(36894320,1))+1  --"墓地回收"
		end
	end
	if op==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(0)
		e:SetOperation(c36894320.spop)
		c36894320.cost(e,tp,eg,ep,ev,re,r,rp,1)
		c36894320.sptg(e,tp,eg,ep,ev,re,r,rp,1)
	elseif op==1 then
		e:SetCategory(CATEGORY_TODECK)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(c36894320.tdop)
		c36894320.cost(e,tp,eg,ep,ev,re,r,rp,1)
		c36894320.tdtg(e,tp,eg,ep,ev,re,r,rp,1)
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
-- 规则层面：设置效果发动次数限制，每回合只能发动一次。
function c36894320.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(36894320)==0 end
	c:RegisterFlagEffect(36894320,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 规则层面：判断当前是否处于主要阶段。
function c36894320.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取当前阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 规则层面：过滤满足条件的「时械神」怪兽。
function c36894320.spfilter(c,e,tp)
	return c:IsSetCard(0x4a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面：设置特殊召唤效果的目标和条件。
function c36894320.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查是否有足够的召唤位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面：检查手牌中是否存在满足条件的「时械神」怪兽。
		and Duel.IsExistingMatchingCard(c36894320.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 规则层面：设置特殊召唤效果的处理信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 规则层面：执行特殊召唤操作。
function c36894320.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：检查是否满足特殊召唤条件。
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 规则层面：提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面：选择满足条件的1只「时械神」怪兽。
	local g=Duel.SelectMatchingCard(tp,c36894320.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 规则层面：将选中的怪兽特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 规则层面：过滤满足条件的「时械神」怪兽（可返回卡组）。
function c36894320.tdfilter(c)
	return c:IsSetCard(0x4a) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 规则层面：设置墓地回收效果的目标和条件。
function c36894320.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c36894320.tdfilter(chkc) end
	-- 规则层面：检查自己墓地中是否存在满足条件的「时械神」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c36894320.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 规则层面：提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 规则层面：选择满足条件的1只「时械神」怪兽。
	local g=Duel.SelectTarget(tp,c36894320.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 规则层面：设置墓地回收效果的处理信息。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 规则层面：过滤满足条件的「无限光」卡（可盖放）。
function c36894320.setfilter(c)
	return c:IsCode(72883039) and c:IsSSetable()
end
-- 规则层面：执行墓地回收效果的后续处理。
function c36894320.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取当前连锁的目标卡。
	local tc=Duel.GetFirstTarget()
	-- 规则层面：检查目标卡是否有效并将其送入卡组。
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_DECK) then
		-- 规则层面：获取满足条件的「无限光」卡。
		local g=Duel.GetMatchingGroup(c36894320.setfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
		-- 规则层面：询问玩家是否盖放「无限光」。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(36894320,2)) then  --"是否盖放「无限光」？"
			local sc=g:Select(tp,1,1,nil):GetFirst()
			-- 规则层面：将选中的「无限光」盖放于魔法与陷阱区域。
			Duel.SSet(tp,sc)
		end
	end
end
