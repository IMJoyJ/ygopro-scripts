--デッキロック
-- 效果：
-- 只要这张卡在场上存在，双方不能用抽卡以外的方法从卡组把卡加入手卡，也不能作从卡组的特殊召唤。发动后第2次的自己的准备阶段时这张卡破坏。
function c1149109.initial_effect(c)
	-- 这张卡发动后，第2次的自己准备阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c1149109.target)
	c:RegisterEffect(e1)
	-- 双方不能用抽卡以外的方法从卡组把卡加入手卡
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_TO_HAND)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	-- 设置不能加入手卡的限制仅以卡组中的卡为对象，即只有从卡组加入手卡的行为才会被禁止。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_DECK))
	c:RegisterEffect(e2)
	-- 也不能从卡组把怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetTargetRange(LOCATION_DECK,LOCATION_DECK)
	c:RegisterEffect(e3)
end
-- 发动时把本卡的回合计数器清零，并注册一个不可被无效的连续效果：在每个自己准备阶段检查计数，到第2次自己准备阶段时破坏这张卡。
function c1149109.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	c:SetTurnCounter(0)
	-- 这张卡发动后，第2次的自己准备阶段破坏。
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
-- 判定触发时机是否为自己的准备阶段，即当前回合玩家是否为这张卡的控制者。
function c1149109.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件为当前回合玩家等于这张卡的控制者tp，即只有自己回合的准备阶段才满足触发条件。
	return tp==Duel.GetTurnPlayer()
end
-- 每次触发时将回合计数器加1，当计数达到2时以规则原因破坏这张卡。
function c1149109.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==2 then
		-- 以规则原因将这张卡破坏，此破坏不进入连锁，不受“不会被效果破坏”等效果影响。
		Duel.Destroy(c,REASON_RULE)
	end
end
