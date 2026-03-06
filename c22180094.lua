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
	-- ②：从手卡把1张「治安战警队」卡除外才能发动。这张卡回到持有者手卡，从卡组把「治安战警队 乱破小夜丸」以外的1只「治安战警队」怪兽守备表示特殊召唤。这个效果在对方回合也能发动。
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
-- 过滤函数，用于判断目标怪兽是否为己方「治安战警队」怪兽。
function c22180094.atfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x156) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- 判断目标怪兽是否在己方场上，并且与当前怪兽在同一纵列。
function c22180094.attg(e,c)
	local cg=c:GetColumnGroup()
	e:SetLabelObject(c)
	return cg:IsExists(c22180094.atfilter,1,nil,e:GetHandlerPlayer())
end
-- 限制对方怪兽不能攻击非同纵列的己方怪兽。
function c22180094.atlimit(e,c)
	local lc=e:GetLabelObject()
	return not lc:GetColumnGroup():IsContains(c)
end
-- 过滤函数，用于判断手卡或墓地中的「治安战警队」卡是否可以作为除外的代价。
function c22180094.costfilter(c,e,tp)
	if c:IsLocation(LOCATION_HAND) then
		return c:IsSetCard(0x156) and c:IsAbleToRemoveAsCost()
	else
		return e:GetHandler():IsSetCard(0x156) and c:IsHasEffect(55049722,tp) and c:IsAbleToRemoveAsCost()
	end
end
-- 处理效果发动的除外代价，根据是否拥有特定效果来决定除外方式。
function c22180094.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的「治安战警队」卡可以作为除外的代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c22180094.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的「治安战警队」卡作为除外的代价。
	local tg=Duel.SelectMatchingCard(tp,c22180094.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local te=tg:GetFirst():IsHasEffect(55049722,tp)
	if te then
		te:UseCountLimit(tp)
		-- 以代替方式将选中的卡除外。
		Duel.Remove(tg,POS_FACEUP,REASON_REPLACE)
	else
		-- 以代价方式将选中的卡除外。
		Duel.Remove(tg,POS_FACEUP,REASON_COST)
	end
end
-- 过滤函数，用于筛选可以特殊召唤的「治安战警队」怪兽。
function c22180094.spfilter(c,e,tp)
	return c:IsSetCard(0x156) and not c:IsCode(22180094) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置效果发动时的操作信息，包括回手和特殊召唤。
function c22180094.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足发动条件：自身可以回手、场上存在空位、卡组存在符合条件的怪兽。
	if chk==0 then return c:IsAbleToHand() and Duel.GetMZoneCount(tp,c)>0 and Duel.IsExistingMatchingCard(c22180094.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：将自身送回手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	-- 设置操作信息：从卡组特殊召唤一只「治安战警队」怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理效果发动后的操作：将自身送回手牌并从卡组特殊召唤一只怪兽。
function c22180094.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查效果是否可以发动：自身在场、可以送回手牌、场上存在空位。
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_HAND) and Duel.GetMZoneCount(tp)>0 then
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的「治安战警队」怪兽进行特殊召唤。
		local g=Duel.SelectMatchingCard(tp,c22180094.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			-- 将选中的怪兽以守备表示特殊召唤到场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
