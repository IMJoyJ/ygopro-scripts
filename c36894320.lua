--無限械アイン・ソフ
-- 效果：
-- 把自己的魔法与陷阱区域1张表侧表示的「虚无械」送去墓地才能把这张卡发动。
-- ①：这张卡1回合只有1次不会被对方的效果破坏。
-- ②：1回合1次，可以从以下效果选择1个发动。
-- ●自己·对方的主要阶段才能发动。从手卡把1只「时械神」怪兽特殊召唤。
-- ●以自己墓地1只「时械神」怪兽为对象才能发动。那只怪兽回到卡组。那之后，可以从手卡·卡组选1张「无限光」在自己的魔法与陷阱区域盖放。
function c36894320.initial_effect(c)
	-- 把自己的魔法与陷阱区域1张表侧表示的「虚无械」送去墓地才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c36894320.actcost)
	e1:SetTarget(c36894320.acttg)
	c:RegisterEffect(e1)
	-- ①：这张卡1回合只有1次不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetCountLimit(1)
	e2:SetValue(c36894320.valcon)
	c:RegisterEffect(e2)
	-- ●自己·对方的主要阶段才能发动。从手卡把1只「时械神」怪兽特殊召唤。
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
	-- ●以自己墓地1只「时械神」怪兽为对象才能发动。那只怪兽回到卡组。那之后，可以从手卡·卡组选1张「无限光」在自己的魔法与陷阱区域盖放。
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
-- 判定该卡的抗破坏效果：仅当破坏原因为效果且破坏方为对方时，触发1回合1次的不会被效果破坏的防护。
function c36894320.valcon(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and rp==1-e:GetHandlerPlayer()
end
-- 发动代价的筛选条件：己方魔陷区表侧表示的卡名「虚无械」且可以作为代价送去墓地。
function c36894320.acfilter(c)
	return c:IsFaceup() and c:IsCode(9409625) and c:IsAbleToGraveAsCost()
end
-- 发动代价处理：选择并把自己魔陷区1张表侧表示的「虚无械」送去墓地作为发动代价。
function c36894320.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认己方魔陷区存在至少1张表侧「虚无械」以供作为发动代价送墓。
	if chk==0 then return Duel.IsExistingMatchingCard(c36894320.acfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡（选择提示消息）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从己方魔陷区选择1张满足acfilter的「虚无械」作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c36894320.acfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 将选择的「虚无械」作为发动代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 发动时的目标处理：检查②的两个可选效果（特殊召唤/回卡组+盖放）是否可发动，让玩家选择其中一个分支，并将当前发动的操作设置为对应效果，同时消耗1回合1次的使用次数。
function c36894320.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return c36894320.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
	if chk==0 then return true end
	local b1=c36894320.spcon(e,tp,eg,ep,ev,re,r,rp)
		and c36894320.cost(e,tp,eg,ep,ev,re,r,rp,0)
		and c36894320.sptg(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=c36894320.cost(e,tp,eg,ep,ev,re,r,rp,0)
		and c36894320.tdtg(e,tp,eg,ep,ev,re,r,rp,0)
	local op=-1
	-- 若至少一个可选效果满足条件，则询问玩家是否发动效果；选择‘是’才继续。
	if (b1 or b2) and Duel.SelectYesNo(tp,94) then
		if b1 and b2 then
			-- 两个分支都可用时，让玩家选择要发动的效果：选项0为特殊召唤，选项1为墓地回收。
			op=Duel.SelectOption(tp,aux.Stringid(36894320,0),aux.Stringid(36894320,1))  --"特殊召唤/墓地回收"
		elseif b1 then
			-- 仅特殊召唤分支可用时，让玩家选择该分支（返回0）。
			op=Duel.SelectOption(tp,aux.Stringid(36894320,0))  --"特殊召唤"
		else
			-- 仅墓地回收分支可用时，让玩家选择该分支；返回0后+1作为墓地回收分支的分支序号。
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
-- ②效果的1回合1次使用限制：检查该卡本回合是否已经发动过②效果，若未发动则注册flag标记并在回合结束重置。
function c36894320.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(36894320)==0 end
	c:RegisterFlagEffect(36894320,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 特殊召唤分支的发动条件：当前必须处于主要阶段（自己或对方的主要阶段）。
function c36894320.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段，用于判断是否处于主要阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 筛选条件：卡属于「时械神」系列，且可以被当前效果特殊召唤。
function c36894320.spfilter(c,e,tp)
	return c:IsSetCard(0x4a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤分支的目标检查：自己主要怪兽区有空位，且手卡存在符合条件的「时械神」怪兽。
function c36894320.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足spfilter的「时械神」怪兽。
		and Duel.IsExistingMatchingCard(c36894320.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果将进行从手卡特殊召唤1只怪兽的特殊召唤处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤分支的效果处理：若本卡仍与效果关联且场上空位足够，则从手卡选择1只「时械神」怪兽表侧表示特殊召唤。
function c36894320.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前检查：若本卡已与效果失去关联（如离场）或怪兽区无空位则终止处理。
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只满足spfilter的「时械神」怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c36894320.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「时械神」怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 筛选条件：墓地的「时械神」怪兽且可以回到卡组。
function c36894320.tdfilter(c)
	return c:IsSetCard(0x4a) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 墓地回收分支的目标处理：取自己墓地1只「时械神」怪兽为对象，确认后设置回卡组的操作信息。
function c36894320.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c36894320.tdfilter(chkc) end
	-- 检查自己墓地是否存在至少1只满足tdfilter的「时械神」怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c36894320.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地选择1只「时械神」怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c36894320.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本次效果将使对象怪兽回到卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 筛选条件：卡名「无限光」且可以在魔法与陷阱区域盖放。
function c36894320.setfilter(c)
	return c:IsCode(72883039) and c:IsSSetable()
end
-- 墓地回收分支的效果处理：将对象「时械神」怪兽洗回卡组；若成功回到卡组，则从手卡·卡组选1张「无限光」盖放到自己的魔法与陷阱区域。
function c36894320.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时的对象卡（墓地的「时械神」怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 若对象仍与效果关联，则将其洗回持有者卡组；只有回卡组成功才继续后续处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_DECK) then
		-- 获取手卡·卡组中所有可盖放的「无限光」卡片组，供玩家选择。
		local g=Duel.GetMatchingGroup(c36894320.setfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
		-- 若存在可盖放的「无限光」，询问玩家是否从其中选择1张盖放。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(36894320,2)) then  --"是否盖放「无限光」？"
			local sc=g:Select(tp,1,1,nil):GetFirst()
			-- 将玩家选择的「无限光」盖放到自己的魔法与陷阱区域。
			Duel.SSet(tp,sc)
		end
	end
end
