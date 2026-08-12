--デッキロック
-- 效果：
-- 只要这张卡在场上存在，双方不能用抽卡以外的方法从卡组把卡加入手卡，也不能作从卡组的特殊召唤。发动后第2次的自己的准备阶段时这张卡破坏。
function c1149109.initial_effect(c)
	-- 发动后第2次的自己的准备阶段时这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c1149109.target)
	c:RegisterEffect(e1)
	-- 双方不能用抽卡以外的方法从卡组把卡加入手卡，也不能作从卡组的特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_TO_HAND)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	-- 设置目标为位于卡组的卡片。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_DECK))
	c:RegisterEffect(e2)
	-- 双方不能用抽卡以外的方法从卡组把卡加入手卡，也不能作从卡组的特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetTargetRange(LOCATION_DECK,LOCATION_DECK)
	c:RegisterEffect(e3)
end
-- 设置效果触发条件为准备阶段。
function c1149109.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	c:SetTurnCounter(0)
	-- 设置效果触发条件为准备阶段。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c1149109.descon)
	e1:SetOperation(c1149109.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
	c:RegisterEffect(e1)
end
-- 判断是否为当前回合玩家的准备阶段。
function c1149109.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家。
	return tp==Duel.GetTurnPlayer()
end
-- 设置破坏效果的执行函数。
function c1149109.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==2 then
		-- 将该卡以规则破坏。
		Duel.Destroy(c,REASON_RULE)
	end
end
