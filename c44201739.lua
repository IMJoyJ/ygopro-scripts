--ミラァと燐寸之仔
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合才能发动。同名卡在对方墓地存在的3张卡从手卡·卡组给对方观看（同名卡最多1张），这张卡特殊召唤。
-- ②：对方把魔法·陷阱·怪兽的效果发动时，把这张卡的①的效果特殊召唤的这张卡送去墓地才能发动。把1张对方发动的那张卡的同名卡从卡组·额外卡组送去墓地，那个发动无效。
function c44201739.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡在手卡存在的场合才能发动。同名卡在对方墓地存在的3张卡从手卡·卡组给对方观看（同名卡最多1张），这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44201739,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,44201739)
	e1:SetTarget(c44201739.sptg)
	e1:SetOperation(c44201739.spop)
	c:RegisterEffect(e1)
	-- ②：对方把魔法·陷阱·怪兽的效果发动时，把这张卡的①的效果特殊召唤的这张卡送去墓地才能发动。把1张对方发动的那张卡的同名卡从卡组·额外卡组送去墓地，那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44201739,1))  --"发动无效"
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,44201739+1)
	e2:SetCondition(c44201739.negcon)
	e2:SetCost(c44201739.negcost)
	e2:SetTarget(c44201739.negtg)
	e2:SetOperation(c44201739.negop)
	c:RegisterEffect(e2)
end
-- 定义候选卡过滤函数：对方墓地存在至少1张同名卡且该卡当前非公开状态，用于手卡·卡组中挑选可展示的卡。
function c44201739.cfilter(c,tp)
	-- 判断对方墓地是否存在与此卡当前卡号相同的卡（至少1张）且此卡不是公开状态。
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,0,LOCATION_GRAVE,1,nil,c:GetCode()) and not c:IsPublic()
end
-- ①效果发动条件判定：从手卡·卡组中获取候选组，确认能否选出3张卡名互不相同的卡、我方怪兽区有空位且此卡可被特殊召唤。
function c44201739.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取我方手卡·卡组中所有满足cfilter条件的卡片作为候选组。
	local g=Duel.GetMatchingGroup(c44201739.cfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,tp)
	-- 发动合法性检查：候选组能否选出3张卡名互不相同的卡，且我方主要怪兽区有空位。
	if chk==0 then return g:CheckSubGroup(aux.dncheck,3,3) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果将特殊召唤此卡，操作分类为特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：从候选组中选择3张卡名互不相同的卡给对方确认，随后洗切手卡·卡组，并将此卡特殊召唤。
function c44201739.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时重新获取我方手卡·卡组中满足条件的候选组。
	local g=Duel.GetMatchingGroup(c44201739.cfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,tp)
	-- 确认候选组仍能选出3张卡名互不相同的卡。
	if g:CheckSubGroup(aux.dncheck,3,3) then
		-- 弹出选择提示，要求玩家选择给对方确认的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 从候选组中选择3张卡名互不相同的卡。
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,3,3,nil)
		-- 将选中的3张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg)
		-- 洗切手卡以隐藏手卡顺序信息。
		Duel.ShuffleHand(tp)
		-- 洗切卡组以隐藏卡组顺序信息。
		Duel.ShuffleDeck(tp)
		if not c:IsRelateToEffect(e) then return end
		-- 将此卡以表侧表示特殊召唤到我方怪兽区，召唤类型记为本卡自身效果。
		Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果发动条件：此卡未处于战斗破坏确定状态、对方发动效果且该连锁可被无效。
function c44201739.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断此卡非战斗破坏确定、效果发动者是对方且连锁可无效。
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep~=tp and Duel.IsChainNegatable(ev)
end
-- ②效果代价判定与执行：此卡必须是由①效果特殊召唤的（召唤类型为特殊召唤+自身效果）且可作为代价送墓；执行时将此卡送墓作为代价。
function c44201739.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF and e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送去墓地作为发动代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 定义送墓对象过滤条件：与对方发动的效果持有者当前卡号相同且可以被送去墓地。
function c44201739.filter(c,re)
	return c:IsCode(re:GetHandler():GetCode()) and c:IsAbleToGrave()
end
-- ②效果发动时点：确认自己卡组·额外卡组存在与对方发动的那张卡同名的卡；设置操作信息为无效对方发动及把同名卡送去墓地。
function c44201739.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在至少1张与对方发动的效果持有者同名的卡，且可从卡组·额外卡组送去墓地。
	if chk==0 then return Duel.IsExistingMatchingCard(c44201739.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,re) end
	-- 设置操作信息：本次效果将无效对方发动的连锁（对象为该连锁涉及的那张卡）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 设置操作信息：本次效果将从自己卡组·额外卡组把1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- ②效果处理：从自己卡组·额外卡组选择1张与对方发动的那张卡同名的卡送去墓地；若送墓成功，则无效对方那个发动。
function c44201739.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，要求玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从己方卡组·额外卡组选择1张符合条件的同名卡。
	local g=Duel.SelectMatchingCard(tp,c44201739.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,re)
	-- 判断选到的卡存在、成功送去墓地且该卡确实在墓地。
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 使对方发动的那个连锁无效。
		Duel.NegateActivation(ev)
	end
end
