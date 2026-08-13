--トラップ・キャプチャー
-- 效果：
-- 自己把陷阱卡发动时，丢弃1张手卡连锁发动。连锁发动的陷阱卡被送去墓地时，那张卡回到手卡。
function c2122975.initial_effect(c)
	-- 自己把陷阱卡发动时，丢弃1张手卡连锁发动。连锁发动的陷阱卡被送去墓地时，那张卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c2122975.condition)
	e1:SetCost(c2122975.cost)
	e1:SetOperation(c2122975.activate)
	c:RegisterEffect(e1)
end
-- 判断当前连锁发动的效果是否为使用者自己发动的陷阱卡的发动（EFFECT_TYPE_ACTIVATE 且 TYPE_TRAP），即满足『自己把陷阱卡发动时』的触发条件。
function c2122975.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP)
end
-- 发动代价：丢弃1张手卡。该函数在检查阶段确认代价可支付，并在发动时实际从手牌丢弃1张卡。
function c2122975.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己的手牌中存在至少1张可以丢弃的卡（排除本卡），否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际支付代价：从手牌选择1张可以丢弃的卡，以「代价＋丢弃」的理由丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 发动成功后的处理：若连锁发动的陷阱卡仍与那次连锁关联（没有因连锁处理离开预期区域），则给该陷阱卡注册一个持续效果，使其在之后被送去墓地时触发回收。
function c2122975.activate(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 连锁发动的陷阱卡被送去墓地时，那张卡回到手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_TO_GRAVE)
		e1:SetOperation(c2122975.thop)
		e1:SetReset(RESET_EVENT+0x17a0000)
		re:GetHandler():RegisterEffect(e1)
	end
end
-- 触发回收的效果处理：当被注册的陷阱卡被送去墓地时，若其没有受到「王家长眠之谷」效果的影响，则将其返回手卡。
function c2122975.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsHasEffect(EFFECT_NECRO_VALLEY) then
		-- 将被送去墓地的该陷阱卡，以效果处理的方式送回手卡。
		Duel.SendtoHand(e:GetHandler(),tp,REASON_EFFECT)
	end
end
