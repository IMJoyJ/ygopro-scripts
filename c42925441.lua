--フォトン・チェンジ
-- 效果：
-- 这张卡发动后，第2次的自己准备阶段送去墓地。这个卡名的①的效果1回合只能使用1次。
-- ①：可以把自己场上的表侧表示的1只「光子」怪兽或者「银河」怪兽送去墓地，从以下效果选择1个发动。把「银河眼光子龙」送去墓地发动的场合，可以选择两方。
-- ●原本卡名和那只怪兽不同的1只「光子」怪兽从卡组特殊召唤。
-- ●从卡组把「光子变身」以外的1张「光子」卡加入手卡。
function c42925441.initial_effect(c)
	-- 此效果为卡名的①的效果，1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c42925441.target)
	c:RegisterEffect(e1)
	-- 可以把自己场上的表侧表示的1只「光子」怪兽或者「银河」怪兽送去墓地，从以下效果选择1个发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(42925441,0))  --"选择效果发动"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1,42925441)
	e4:SetHintTiming(0,TIMING_END_PHASE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCost(c42925441.effcost)
	e4:SetTarget(c42925441.efftg)
	e4:SetOperation(c42925441.effop)
	c:RegisterEffect(e4)
end
-- 将此卡注册为发动效果的处理函数。
function c42925441.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 此效果为卡名的①的效果，1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42925441,4))  --"回合计数"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c42925441.descon)
	e1:SetOperation(c42925441.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
	c:SetTurnCounter(0)
	c:RegisterEffect(e1)
	if c42925441.effcost(e,tp,eg,ep,ev,re,r,rp,0)
		and c42925441.efftg(e,tp,eg,ep,ev,re,r,rp,0)
		-- 询问玩家是否发动效果。
		and Duel.SelectYesNo(tp,94) then
		c42925441.effcost(e,tp,eg,ep,ev,re,r,rp,1)
		c42925441.efftg(e,tp,eg,ep,ev,re,r,rp,1)
		e:SetOperation(c42925441.effop)
	end
end
-- 判断是否为当前回合玩家。
function c42925441.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家。
	return Duel.GetTurnPlayer()==tp
end
-- 当准备阶段时，将此卡的回合计数器加1。
function c42925441.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==2 then
		-- 当回合计数器达到2时，将此卡送去墓地。
		Duel.SendtoGrave(c,REASON_RULE)
	end
end
-- 设置效果的发动条件，确保每回合只能发动一次。
function c42925441.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(42925441)==0 end
	e:GetHandler():RegisterFlagEffect(42925441,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 检查场上是否有满足条件的「光子」或「银河」怪兽可以作为cost。
function c42925441.costfilter1(c,e,tp)
	-- 检查场上是否有满足条件的「光子」或「银河」怪兽可以作为cost。
	return c:IsFaceup() and c:IsSetCard(0x55,0x7b) and Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToGraveAsCost()
		-- 检查卡组中是否存在满足条件的「光子」怪兽。
		and Duel.IsExistingMatchingCard(c42925441.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
-- 检查卡组中是否存在满足条件的「光子」怪兽。
function c42925441.spfilter1(c,e,tp,cc)
	return c:IsSetCard(0x55) and c:IsType(TYPE_MONSTER) and not c:IsOriginalCodeRule(cc:GetOriginalCodeRule())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查场上是否有满足条件的「光子」或「银河」怪兽可以作为cost。
function c42925441.costfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x55,0x7b) and c:IsAbleToGraveAsCost()
end
-- 检查卡组中是否存在满足条件的「光子」卡。
function c42925441.thfilter(c)
	return c:IsSetCard(0x55) and not c:IsCode(42925441) and c:IsAbleToHand()
end
-- 检查场上是否有「银河眼光子龙」可以作为cost。
function c42925441.costfilter3(c,e,tp)
	-- 检查场上是否有「银河眼光子龙」可以作为cost。
	return c:IsFaceup() and c:IsCode(93717133) and Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToGraveAsCost()
		-- 检查卡组中是否存在满足条件的「光子」怪兽。
		and Duel.IsExistingMatchingCard(c42925441.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
-- 检查卡组中是否存在满足条件的「光子」怪兽。
function c42925441.spfilter2(c,e,tp,cc)
	-- 检查卡组中是否存在满足条件的「光子」怪兽。
	return c42925441.spfilter1(c,e,tp,cc) and Duel.IsExistingMatchingCard(c42925441.thfilter,tp,LOCATION_DECK,0,1,c)
end
-- 设置效果的处理函数，包括选择效果和处理效果。
function c42925441.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的「光子」或「银河」怪兽。
	local b1=Duel.IsExistingMatchingCard(c42925441.costfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp)
	-- 检查场上是否存在满足条件的「光子」或「银河」怪兽。
	local b2=Duel.IsExistingMatchingCard(c42925441.costfilter2,tp,LOCATION_MZONE,0,1,nil)
		-- 检查卡组中是否存在满足条件的「光子」卡。
		and Duel.IsExistingMatchingCard(c42925441.thfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	-- 检查场上是否存在「银河眼光子龙」。
	local b3=Duel.IsExistingMatchingCard(c42925441.costfilter3,tp,LOCATION_MZONE,0,1,nil,e,tp)
	local op=0
	if b1 and b2 and b3 then
		-- 选择效果1：特殊召唤。
		op=Duel.SelectOption(tp,aux.Stringid(42925441,1),aux.Stringid(42925441,2),aux.Stringid(42925441,3))  --"特殊召唤/卡组检索/我全都要"
	elseif b1 and b2 then
		-- 选择效果2：卡组检索。
		op=Duel.SelectOption(tp,aux.Stringid(42925441,1),aux.Stringid(42925441,2))  --"特殊召唤/卡组检索"
	elseif b1 then
		-- 选择效果1：特殊召唤。
		op=Duel.SelectOption(tp,aux.Stringid(42925441,1))  --"特殊召唤"
	else
		-- 选择效果2：卡组检索。
		op=Duel.SelectOption(tp,aux.Stringid(42925441,2))+1  --"卡组检索"
	end
	e:SetLabel(op)
	if op==0 then
		-- 提示玩家选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择要送去墓地的「光子」或「银河」怪兽。
		local g=Duel.SelectMatchingCard(tp,c42925441.costfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
		e:SetLabelObject(g:GetFirst())
		-- 将选中的怪兽送去墓地。
		Duel.SendtoGrave(g,REASON_COST)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 设置操作信息，准备特殊召唤。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	elseif op==1 then
		-- 提示玩家选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择要送去墓地的「光子」或「银河」怪兽。
		local g=Duel.SelectMatchingCard(tp,c42925441.costfilter2,tp,LOCATION_MZONE,0,1,1,nil)
		-- 将选中的怪兽送去墓地。
		Duel.SendtoGrave(g,REASON_COST)
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		-- 设置操作信息，准备卡组检索。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		-- 提示玩家选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择要送去墓地的「银河眼光子龙」。
		local g=Duel.SelectMatchingCard(tp,c42925441.costfilter3,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
		e:SetLabelObject(g:GetFirst())
		-- 将选中的怪兽送去墓地。
		Duel.SendtoGrave(g,REASON_COST)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
		-- 设置操作信息，准备特殊召唤。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
		-- 设置操作信息，准备卡组检索。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
-- 执行效果处理函数。
function c42925441.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local cc=e:GetLabelObject()
	local res=0
	if op~=1 then
		-- 检查是否有足够的怪兽区。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择要特殊召唤的「光子」怪兽。
		local g=Duel.SelectMatchingCard(tp,c42925441.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp,cc)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤。
			res=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	if op~=0 then
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择要加入手牌的「光子」卡。
		local g=Duel.SelectMatchingCard(tp,c42925441.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 如果选择效果3且已特殊召唤，则中断效果。
			if op==2 and res~=0 then Duel.BreakEffect() end
			-- 将选中的卡加入手牌。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认对方看到加入手牌的卡。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
