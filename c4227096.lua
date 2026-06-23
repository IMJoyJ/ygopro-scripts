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
-- 将效果注册为永续Field效果，使双方不能将卡从卡组加入手牌
function c4227096.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 直到下次的自己回合的结束时，双方不能用抽卡以外的方法从卡组把卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TO_HAND)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	-- 设定目标为位于卡组的卡片
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_DECK))
	-- 判断当前回合玩家是否为使用者
	if Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
	end
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
