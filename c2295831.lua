--ピースの輪
-- 效果：
-- ①：对方场上有怪兽3只以上存在，自己场上没有卡存在的场合，自己抽卡阶段通过把通常抽卡的这张卡持续公开，那个回合的主要阶段1才能发动。自己从卡组选1张卡，给双方确认加入手卡。
function c2295831.initial_effect(c)
	-- 效果原文：①：对方场上有怪兽3只以上存在，自己场上没有卡存在的场合，自己抽卡阶段通过把通常抽卡的这张卡持续公开，那个回合的主要阶段1才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(c2295831.regcon)
	e1:SetOperation(c2295831.regop)
	c:RegisterEffect(e1)
	-- 效果原文：自己从卡组选1张卡，给双方确认加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(c2295831.condition)
	e2:SetCost(c2295831.cost)
	e2:SetTarget(c2295831.target)
	e2:SetOperation(c2295831.activate)
	c:RegisterEffect(e2)
end
-- 规则层面：判断是否满足发动条件，即自己场上没有卡，对方场上怪兽数量不少于3，当前处于抽卡阶段且该卡因规则而被抽到。
function c2295831.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面：检查自己场上是否没有卡，对方场上怪兽数量是否不少于3。
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>=3
		-- 规则层面：检查当前阶段是否为抽卡阶段且该卡因规则被抽到。
		and Duel.GetCurrentPhase()==PHASE_DRAW and c:IsReason(REASON_RULE)
end
-- 规则层面：询问玩家是否要持续公开此卡，若选择公开则设置公开效果并注册标志。
function c2295831.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面：询问玩家是否要持续公开「拼图之圈」。
	if Duel.SelectYesNo(tp,aux.Stringid(2295831,0)) then  --"是否要持续公开「拼图之圈」？"
		-- 效果原文：自己抽卡阶段通过把通常抽卡的这张卡持续公开。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PUBLIC)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_MAIN1)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(2295831,RESET_PHASE+PHASE_MAIN1,EFFECT_FLAG_CLIENT_HINT,1,0,66)
	end
end
-- 规则层面：判断是否处于主要阶段1。
function c2295831.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：检查当前阶段是否为主要阶段1。
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 规则层面：检查是否已通过条件判断并注册了标志，以确认是否可以发动效果。
function c2295831.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(2295831)~=0 end
end
-- 规则层面：检查是否可以检索卡组中的卡并设置操作信息。
function c2295831.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查卡组中是否存在至少一张可以加入手牌的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,1,nil) end
	-- 规则层面：设置操作信息，表示将从卡组选择一张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 规则层面：执行效果，选择卡组中的卡加入手牌并确认给对方查看。
function c2295831.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面：从卡组中选择一张可以加入手牌的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面：将选中的卡送入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 规则层面：确认将要加入手牌的卡给对方查看。
		Duel.ConfirmCards(1-tp,g)
	end
end
