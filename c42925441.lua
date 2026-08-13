--フォトン・チェンジ
-- 效果：
-- 这张卡发动后，第2次的自己准备阶段送去墓地。这个卡名的①的效果1回合只能使用1次。
-- ①：可以把自己场上的表侧表示的1只「光子」怪兽或者「银河」怪兽送去墓地，从以下效果选择1个发动。把「银河眼光子龙」送去墓地发动的场合，可以选择两方。
-- ●原本卡名和那只怪兽不同的1只「光子」怪兽从卡组特殊召唤。
-- ●从卡组把「光子变身」以外的1张「光子」卡加入手卡。
function c42925441.initial_effect(c)
	-- 这张卡发动后，第2次的自己准备阶段送去墓地。这个卡名的①的效果1回合只能使用1次。①：可以把自己场上的表侧表示的1只「光子」怪兽或者「银河」怪兽送去墓地，从以下效果选择1个发动。把「银河眼光子龙」送去墓地发动的场合，可以选择两方。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c42925441.target)
	c:RegisterEffect(e1)
	-- ①：可以把自己场上的表侧表示的1只「光子」怪兽或者「银河」怪兽送去墓地，从以下效果选择1个发动。把「银河眼光子龙」送去墓地发动的场合，可以选择两方。●原本卡名和那只怪兽不同的1只「光子」怪兽从卡组特殊召唤。●从卡组把「光子变身」以外的1张「光子」卡加入手卡。
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
-- 魔法卡发动时的效果处理：若chk==0则直接放行；否则为本卡注册“第2次自己准备阶段自毁”的计数效果，并在满足①发动条件时询问玩家是否发动①效果。
function c42925441.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 这张卡发动后，第2次的自己准备阶段送去墓地。
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
		-- 询问玩家是否选择发动①效果，选择“是”则立即执行①的cost和目标处理。
		and Duel.SelectYesNo(tp,94) then
		c42925441.effcost(e,tp,eg,ep,ev,re,r,rp,1)
		c42925441.efftg(e,tp,eg,ep,ev,re,r,rp,1)
		e:SetOperation(c42925441.effop)
	end
end
-- 自毁效果的触发条件：仅在当前回合玩家是这张卡的持有者（自己回合）的准备阶段才进行计数。
function c42925441.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己的回合，从而保证只在己方准备阶段计数。
	return Duel.GetTurnPlayer()==tp
end
-- 自毁效果的操作：将这张卡的回合计数器加1，当计数器达到2时，以规则理由将这张卡送去墓地。
function c42925441.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==2 then
		-- 以规则理由将这张卡送去墓地，实现“第2次的自己准备阶段送去墓地”。
		Duel.SendtoGrave(c,REASON_RULE)
	end
end
-- ①效果发动前的一次性限制：检查本卡是否已发动过①效果（通过flag效果记录），未发动过才允许发动；发动时给本卡打上flag，保证1回合只能使用1次。
function c42925441.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(42925441)==0 end
	e:GetHandler():RegisterFlagEffect(42925441,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- “特殊召唤”路线的cost过滤器：选择表侧表示的「光子」或「银河」怪兽，该怪兽可以送去墓地，且送去墓地后我方怪兽区有空位，同时卡组中存在满足特殊召唤条件的「光子」怪兽。
function c42925441.costfilter1(c,e,tp)
	-- 判断候选cost怪兽本身：表侧表示、「光子」或「银河」字段、可作为cost送去墓地，且送去墓地后我方怪兽区仍有空格。
	return c:IsFaceup() and c:IsSetCard(0x55,0x7b) and Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToGraveAsCost()
		-- 额外确认卡组中存在能从卡组特殊召唤的合适「光子」怪兽，保证“特殊召唤”路线可选。
		and Duel.IsExistingMatchingCard(c42925441.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
-- 特殊召唤对象的过滤器：卡名含「光子」的怪兽，其原本卡名与作为cost的怪兽不同，且该怪兽可以被效果特殊召唤。
function c42925441.spfilter1(c,e,tp,cc)
	return c:IsSetCard(0x55) and c:IsType(TYPE_MONSTER) and not c:IsOriginalCodeRule(cc:GetOriginalCodeRule())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- “卡组检索”路线的cost过滤器：选择表侧表示的「光子」或「银河」怪兽，仅要求可作为cost送去墓地即可。
function c42925441.costfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x55,0x7b) and c:IsAbleToGraveAsCost()
end
-- 加入手卡对象的过滤器：从卡组选择1张「光子」卡，且不是「光子变身」，并且可以加入手卡。
function c42925441.thfilter(c)
	return c:IsSetCard(0x55) and not c:IsCode(42925441) and c:IsAbleToHand()
end
-- “我全都要”路线的cost过滤器：选择表侧表示的「银河眼光子龙」作为cost，要求送去墓地后我方怪兽区有空位，且卡组中存在既能特殊召唤又能检索的卡的组合。
function c42925441.costfilter3(c,e,tp)
	-- 判断「银河眼光子龙」作为cost的条件：表侧表示、卡号是93717133、可作为cost送去墓地，且送去墓地后我方怪兽区仍有空格。
	return c:IsFaceup() and c:IsCode(93717133) and Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToGraveAsCost()
		-- 额外确认卡组中存在可被特殊召唤的「光子」怪兽，并且该怪兽之外还有可检索的「光子」卡，保证“全都要”路线可选。
		and Duel.IsExistingMatchingCard(c42925441.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
-- “我全都要”的特招对象过滤器：在满足普通特殊召唤条件的基础上，还要求卡组中存在另一张可加入手卡的「光子」卡。
function c42925441.spfilter2(c,e,tp,cc)
	-- 判断该怪兽是否可作为“全都要”路线的特殊召唤对象：满足spfilter1，且卡组中存在除它以外的可检索「光子」卡。
	return c42925441.spfilter1(c,e,tp,cc) and Duel.IsExistingMatchingCard(c42925441.thfilter,tp,LOCATION_DECK,0,1,c)
end
-- ①效果的发动条件判断与处理：根据场上和卡组的情况判断可选择哪些路线，让玩家选择要执行的cost与处理效果，并设定对应的操作信息。
function c42925441.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在能作为“特殊召唤”路线cost的怪兽（costfilter1）。
	local b1=Duel.IsExistingMatchingCard(c42925441.costfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp)
	-- 检查是否存在能作为“卡组检索”路线cost的怪兽（costfilter2）。
	local b2=Duel.IsExistingMatchingCard(c42925441.costfilter2,tp,LOCATION_MZONE,0,1,nil)
		-- 检查卡组中是否有可加入手卡的「光子」卡，使“卡组检索”路线可行。
		and Duel.IsExistingMatchingCard(c42925441.thfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	-- 检查是否存在「银河眼光子龙」作为cost，使同时进行特殊召唤和检索的“全都要”路线可行。
	local b3=Duel.IsExistingMatchingCard(c42925441.costfilter3,tp,LOCATION_MZONE,0,1,nil,e,tp)
	local op=0
	if b1 and b2 and b3 then
		-- 三条路线都可行时，让玩家选择要执行的效果：特殊召唤、卡组检索或两者同时进行。
		op=Duel.SelectOption(tp,aux.Stringid(42925441,1),aux.Stringid(42925441,2),aux.Stringid(42925441,3))  --"特殊召唤/卡组检索/我全都要"
	elseif b1 and b2 then
		-- 只能进行特殊召唤或检索两者之一时，让玩家选择其一。
		op=Duel.SelectOption(tp,aux.Stringid(42925441,1),aux.Stringid(42925441,2))  --"特殊召唤/卡组检索"
	elseif b1 then
		-- 只能进行特殊召唤路线时，直接选择特殊召唤。
		op=Duel.SelectOption(tp,aux.Stringid(42925441,1))  --"特殊召唤"
	else
		-- 只能进行卡组检索路线时，直接选择检索，并令op=1表示执行检索。
		op=Duel.SelectOption(tp,aux.Stringid(42925441,2))+1  --"卡组检索"
	end
	e:SetLabel(op)
	if op==0 then
		-- 提示玩家从自己场上选择1张要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择1张满足costfilter1的「光子」或「银河」怪兽作为“特殊召唤”路线的cost。
		local g=Duel.SelectMatchingCard(tp,c42925441.costfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
		e:SetLabelObject(g:GetFirst())
		-- 将选择的怪兽作为cost送去墓地。
		Duel.SendtoGrave(g,REASON_COST)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 设置操作信息：本次处理后将从卡组特殊召唤1只怪兽。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	elseif op==1 then
		-- 提示玩家从自己场上选择1张要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择1张满足costfilter2的「光子」或「银河」怪兽作为“卡组检索”路线的cost。
		local g=Duel.SelectMatchingCard(tp,c42925441.costfilter2,tp,LOCATION_MZONE,0,1,1,nil)
		-- 将选择的怪兽作为cost送去墓地。
		Duel.SendtoGrave(g,REASON_COST)
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		-- 设置操作信息：本次处理后将从卡组把1张「光子」卡加入手卡。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		-- 提示玩家从自己场上选择1张要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择1张满足costfilter3的「银河眼光子龙」作为“全都要”路线的cost。
		local g=Duel.SelectMatchingCard(tp,c42925441.costfilter3,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
		e:SetLabelObject(g:GetFirst())
		-- 将选择的「银河眼光子龙」作为cost送去墓地。
		Duel.SendtoGrave(g,REASON_COST)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
		-- 设置操作信息：本次处理后将从卡组特殊召唤1只怪兽。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
		-- 设置操作信息：本次处理后将从卡组把1张「光子」卡加入手卡。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
-- ①效果的实际处理：根据玩家选择的路线，从卡组特殊召唤「光子」怪兽和/或把「光子」卡加入手卡；若选择了“全都要”且特殊召唤成功，则用BreakEffect使后续检索另开连锁。
function c42925441.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local cc=e:GetLabelObject()
	local res=0
	if op~=1 then
		-- 进行特殊召唤前检查我方怪兽区是否有空位，若无空位则终止特殊召唤处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1张满足spfilter1的「光子」怪兽作为特殊召唤对象。
		local g=Duel.SelectMatchingCard(tp,c42925441.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp,cc)
		if g:GetCount()>0 then
			-- 将选择的「光子」怪兽以表侧攻击表示特殊召唤，返回成功特殊召唤的数量。
			res=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	if op~=0 then
		-- 提示玩家选择要加入手卡的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1张满足thfilter的「光子」卡作为加入手卡的对象。
		local g=Duel.SelectMatchingCard(tp,c42925441.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 若选择了“全都要”且特殊召唤成功，则中断当前效果处理，使后续加入手卡的效果变为独立处理，避免同一效果内同时进行特招和检索的时点不适。
			if op==2 and res~=0 then Duel.BreakEffect() end
			-- 将选中的「光子」卡加入手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 将加入手卡的卡展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
