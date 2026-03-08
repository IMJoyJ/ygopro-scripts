--老化の呪い
-- 效果：
-- 从手卡丢弃1枚卡，在回合终了前，对方场上所有怪兽攻击力·守备力下降500点。
function c41398771.initial_effect(c)
	-- 效果发动条件：从手卡丢弃1枚卡，在回合终了前，对方场上所有怪兽攻击力·守备力下降500点。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c41398771.cost)
	e1:SetTarget(c41398771.target)
	e1:SetOperation(c41398771.activate)
	c:RegisterEffect(e1)
end
-- 支付代价：丢弃1张手卡。
function c41398771.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃条件。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃操作。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 设定效果目标：对方场上存在表侧表示怪兽。
function c41398771.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在表侧表示怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
-- 效果发动：对对方场上所有表侧表示怪兽造成攻击力和守备力各下降500点的效果。
function c41398771.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示怪兽的集合。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		while tc do
			-- 为怪兽设置攻击力下降500点的效果。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(-500)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			tc:RegisterEffect(e2)
			tc=g:GetNext()
		end
	end
end
