--捕違い
-- 效果：
-- ①：这张卡的发动后，直到下次的自己回合的结束时，双方不能用抽卡以外的方法从卡组把卡加入手卡。
function c4227096.initial_effect(c)
	-- ①：这张卡的发动后，直到下次的自己回合的结束时，双方不能用抽卡以外的方法从卡组把卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c4227096.activate)
	c:RegisterEffect(e1)
end
-- 发动后创建一个影响全场的永续效果，禁止双方玩家通过抽卡以外的方式将卡组中的卡加入手卡；并根据当前是否为自己回合设置合适的重置时机，使效果持续到“下次自己回合结束时”。
function c4227096.activate(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这张卡的发动后，直到下次的自己回合的结束时，双方不能用抽卡以外的方法从卡组把卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TO_HAND)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	-- 设置效果的作用对象条件：只有位于卡组中的卡才会被禁止加入手卡。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_DECK))
	-- 判断当前回合玩家是否为这张卡的发动者：若发动时是自己回合，则重置计数为2，效果持续到下一次自己的结束阶段；否则重置计数为1，在当前结束阶段不会重置，直到自己的结束阶段才失效，由此实现“直到下次自己回合结束时”。
	if Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
	end
	-- 将这个禁止从卡组加入手卡的永续效果注册到场上，使其从此刻开始生效。
	Duel.RegisterEffect(e1,tp)
end
