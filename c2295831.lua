--ピースの輪
-- 效果：
-- ①：对方场上有怪兽3只以上存在，自己场上没有卡存在的场合，自己抽卡阶段通过把通常抽卡的这张卡持续公开，那个回合的主要阶段1才能发动。自己从卡组选1张卡，给双方确认加入手卡。
function c2295831.initial_effect(c)
	-- 自己抽卡阶段通过把通常抽卡的这张卡持续公开
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(c2295831.regcon)
	e1:SetOperation(c2295831.regop)
	c:RegisterEffect(e1)
	-- 那个回合的主要阶段1才能发动。自己从卡组选1张卡，给双方确认加入手卡。
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
-- 抽卡阶段抽到此卡时，判断是否满足“自己场上没有卡、对方场上有3只以上怪兽、当前为抽卡阶段且此卡是通过通常抽卡（规则抽卡）加入手牌”的公开触发条件。
function c2295831.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己场上没有卡存在，且对方场上的怪兽数量在3只以上。
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>=3
		-- 检查当前阶段为抽卡阶段，并且此卡是因为规则（通常抽卡）而抽到的。
		and Duel.GetCurrentPhase()==PHASE_DRAW and c:IsReason(REASON_RULE)
end
-- 抽到该卡后，询问玩家是否要持续公开此卡；若选择是，则给此卡附加持续公开效果，并注册一个用于后续发动判定的flag。
function c2295831.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 弹出选择提示，询问玩家是否要持续公开「拼图之圈」。
	if Duel.SelectYesNo(tp,aux.Stringid(2295831,0)) then  --"是否要持续公开「拼图之圈」？"
		-- 通过把通常抽卡的这张卡持续公开
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PUBLIC)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_MAIN1)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(2295831,RESET_PHASE+PHASE_MAIN1,EFFECT_FLAG_CLIENT_HINT,1,0,66)
	end
end
-- 发动条件：只能在主要阶段1发动，即“那个回合的主要阶段1才能发动”。
function c2295831.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段是否为主要阶段1。
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 作为发动代价/条件，检查此卡是否已经通过“持续公开”处理获得了对应flag，即是否满足“通过把通常抽卡的这张卡持续公开”的限制。
function c2295831.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(2295831)~=0 end
end
-- 效果发动时，从自己卡组选择1张能被加入手卡的卡（不取对象），并设置本次操作的信息为从卡组检索到手牌。
function c2295831.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1张能够加入手卡的卡，作为效果能否发动的合法性条件。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表明这次效果会将1张卡从卡组加入手牌，供后续时点及效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时，从自己卡组选择1张卡，加入手牌，并向对方展示确认。
function c2295831.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示文字，让玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组选择1张能够加入手卡的卡（处理时选择，不取对象）。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
