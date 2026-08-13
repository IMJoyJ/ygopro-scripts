--老化の呪い
-- 效果：
-- 从手卡丢弃1枚卡，在回合终了前，对方场上所有怪兽攻击力·守备力下降500点。
function c41398771.initial_effect(c)
	-- 从手卡丢弃1枚卡，在回合终了前，对方场上所有怪兽攻击力·守备力下降500点。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果发动条件为aux.dscon，即只能在伤害步骤且伤害计算前发动，避免在伤害计算后等不适当时点发动。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c41398771.cost)
	e1:SetTarget(c41398771.target)
	e1:SetOperation(c41398771.activate)
	c:RegisterEffect(e1)
end
-- 发动代价处理：从手卡丢弃1张卡作为代价；先通过chk阶段确认可行，再实际执行丢弃。
function c41398771.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检测：确认自己手牌中存在至少1张可以丢弃的卡（且不丢弃本卡），满足才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际执行代价：从手卡选择1张可丢弃的卡丢弃，丢弃原因标记为代价（REASON_COST+REASON_DISCARD）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果发动时的合法目标检测：确认对方场上有表侧表示怪兽，才能发动；该效果不取对象。
function c41398771.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：确认对方场上存在至少1只表侧表示怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
-- 效果处理：获取对方场上所有表侧表示怪兽，逐只赋予攻击力·守备力下降500的效果，该效果在回合结束时重置。
function c41398771.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上全部表侧表示怪兽，作为后续效果处理的对象集合。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		while tc do
			-- 攻击力下降500点。
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
