--水神の護符
-- 效果：
-- 只要这张卡在场上存在，自己场上的水属性怪兽不会被对方的卡的效果破坏。发动后第3次的对方的结束阶段时这张卡送去墓地。
function c61258740.initial_effect(c)
	-- 发动后第3次的对方的结束阶段时这张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c61258740.target)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，自己场上的水属性怪兽不会被对方的卡的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 过滤受影响的卡片为自己场上的水属性怪兽。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER))
	-- 设置不会被对方的卡的效果破坏。
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
end
-- 卡片发动时的效果处理，初始化回合计数器并注册用于在对方结束阶段将自身送去墓地的延迟效果。
function c61258740.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():SetTurnCounter(0)
	-- 发动后第3次的对方的结束阶段时这张卡送去墓地。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c61258740.tgcon)
	e1:SetOperation(c61258740.tgop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,3)
	e:GetHandler():RegisterEffect(e1)
end
-- 检查当前回合玩家是否为对方，以确保效果只在对方回合的结束阶段触发。
function c61258740.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否不是自己（即当前是对方回合）。
	return Duel.GetTurnPlayer()~=tp
end
-- 对方结束阶段时的效果处理，累加回合计数器，并在达到3次时将这张卡送去墓地。
function c61258740.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==3 then
		-- 因规则原因将这张卡送去墓地。
		Duel.SendtoGrave(c,REASON_RULE)
	end
end
