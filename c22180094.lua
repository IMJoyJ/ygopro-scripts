--S－Force 乱破小夜丸
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己的「治安战警队」怪兽的正对面的对方怪兽只能选择和自身相同纵列的怪兽作为攻击对象。
-- ②：从手卡把1张「治安战警队」卡除外才能发动。这张卡回到持有者手卡，从卡组把「治安战警队 乱破小夜丸」以外的1只「治安战警队」怪兽守备表示特殊召唤。这个效果在对方回合也能发动。
function c22180094.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，自己的「治安战警队」怪兽的正对面的对方怪兽只能选择和自身相同纵列的怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(c22180094.attg)
	e1:SetValue(c22180094.atlimit)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，自己的「治安战警队」怪兽的正对面的对方怪兽只能选择和自身相同纵列的怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(c22180094.attg)
	c:RegisterEffect(e2)
	-- ②：自己·对方回合，从手卡把1张「治安战警队」卡除外才能发动。场上的这张卡回到手卡，从卡组把「治安战警队 乱破小夜丸」以外的1只「治安战警队」怪兽守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(22180094,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,22180094)
	e3:SetCost(c22180094.spcost)
	e3:SetTarget(c22180094.sptg)
	e3:SetOperation(c22180094.spop)
	c:RegisterEffect(e3)
end
-- 过滤自己场上表侧表示的「治安战警队」怪兽。
function c22180094.atfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x156) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- 判断对方场上的怪兽的正对面是否存在自己的表侧表示「治安战警队」怪兽，作为不能选择为攻击对象效果的影响目标判断。
function c22180094.attg(e,c)
	local cg=c:GetColumnGroup()
	e:SetLabelObject(c)
	return cg:IsExists(c22180094.atfilter,1,nil,e:GetHandlerPlayer())
end
-- 限制攻击对象：对方场上的怪兽不能选择自身所在纵列以外的怪兽作为攻击对象。
function c22180094.atlimit(e,c)
	local lc=e:GetLabelObject()
	return not lc:GetColumnGroup():IsContains(c)
end
-- 过滤可以作为发动代价从手卡除外（或受其他卡片效果代替除外）的「治安战警队」卡片。
function c22180094.costfilter(c,e,tp)
	if c:IsHasEffect(55049722,tp) then
		return e:GetHandler():IsSetCard(0x156) and c:IsAbleToRemoveAsCost()
	elseif c:IsHasEffect(11642993,tp) then
		return e:GetHandler():IsSetCard(0x156) and not c:IsCode(11642993)
			and c:IsSetCard(0x156) and c:IsAbleToGraveAsCost()
			-- 判断卡组中是否存在可以被特殊召唤的「治安战警队」怪兽（排除了用作代价的卡本身）。
			and Duel.IsExistingMatchingCard(c22180094.spfilter,tp,LOCATION_DECK,0,1,c,e,tp)
	elseif c:IsLocation(LOCATION_HAND) then
		return c:IsSetCard(0x156) and c:IsAbleToRemoveAsCost()
	end
end
-- ②效果的发动代价处理：从手卡将1张「治安战警队」卡除外（根据适用场上其他卡的效果，也可能是将卡送去墓地或以其他方式代替除外）。
function c22180094.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动前，检查是否存在可以作为发动代价除外的「治安战警队」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c22180094.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil,e,tp) end
	-- 获取所有满足代价过滤条件的卡片组。
	local cg=Duel.GetMatchingGroup(c22180094.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,nil,e,tp)
	if cg:IsExists(Card.IsHasEffect,1,nil,11642993,tp) then
		-- 提示玩家选择要操作的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	else
		-- 提示玩家选择要除外的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	end
	-- 让玩家选择1张用于作为发动代价除外的「治安战警队」卡。
	local tg=Duel.SelectMatchingCard(tp,c22180094.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,e,tp)
	local te=tg:GetFirst():IsHasEffect(11642993,tp)
	if te then
		-- 显示代替除外效果的卡片发动的动画。
		Duel.Hint(HINT_CARD,0,11642993)
		te:UseCountLimit(tp)
		-- 作为效果发动代价，将用于代替除外的卡片送去墓地。
		Duel.SendtoGrave(tg,REASON_COST+REASON_REPLACE)
	else
		local te2=tg:GetFirst():IsHasEffect(55049722,tp)
		if te2 then
			te2:UseCountLimit(tp)
			-- 作为效果发动代价，将卡片除外（以此卡片本身的代替效果）。
			Duel.Remove(tg,POS_FACEUP,REASON_COST+REASON_REPLACE)
		else
			-- 作为效果发动代价，将玩家选择的卡表侧表示除外。
			Duel.Remove(tg,POS_FACEUP,REASON_COST)
		end
	end
end
-- 过滤卡组中除「治安战警队 乱破小夜丸」以外，且可以特殊召唤的「治安战警队」怪兽。
function c22180094.spfilter(c,e,tp)
	return c:IsSetCard(0x156) and not c:IsCode(22180094) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果的发动准备与合法性检查，确认此卡是否能回到手卡，并且检查卡组是否存在可以特殊召唤的「治安战警队」怪兽以及主怪兽区是否有空位，并注册回到手卡和特殊召唤的操作信息。
function c22180094.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断此卡是否能回到手卡，且主怪兽区域有空位，并且卡组中存在可以特殊召唤的「治安战警队」怪兽。
	if chk==0 then return c:IsAbleToHand() and Duel.GetMZoneCount(tp,c)>0 and Duel.IsExistingMatchingCard(c22180094.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息，标记该效果包含将此卡送回手卡的效果分类。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	-- 设置当前连锁的操作信息，标记该效果包含从卡组特殊召唤怪兽的效果分类。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的实效处理：将场上的这张卡送回持有者手卡，如果成功回手并且场上有怪兽格，从卡组选择1只「治安战警队 乱破小夜丸」以外的「治安战警队」怪兽表侧守备表示特殊召唤。
function c22180094.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否仍在场，并将此卡送回手卡，若成功回手且己方怪兽区有空位则进行后续处理。
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_HAND) and Duel.GetMZoneCount(tp)>0 then
		-- 提示玩家选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组中选择1只满足特殊召唤条件的「治安战警队」怪兽。
		local g=Duel.SelectMatchingCard(tp,c22180094.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			-- 将选中的「治安战警队」怪兽守备表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
