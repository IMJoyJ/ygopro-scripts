--マジック・キャプチャー
-- 效果：
-- 自己把魔法卡发动时，丢弃1张手卡连锁发动。连锁发动的魔法卡被送去墓地时，那张卡回到手卡。
function c76137276.initial_effect(c)
	-- 自己把魔法卡发动时，丢弃1张手卡连锁发动。连锁发动的魔法卡被送去墓地时，那张卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c76137276.condition)
	e1:SetCost(c76137276.cost)
	e1:SetOperation(c76137276.activate)
	c:RegisterEffect(e1)
end
-- 检查触发事件的玩家是否为自己，且该连锁是否为魔法卡的发动
function c76137276.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL)
end
-- 检查手牌中是否存在可丢弃的卡，并丢弃1张手牌作为发动代价
function c76137276.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手牌中是否存在至少1张可以丢弃的卡（排除这张卡自身）
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手牌中选择1张卡丢弃送去墓地
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 检查连锁发动的魔法卡是否仍与效果存在联系，若是，则给该魔法卡注册一个送去墓地时回到手牌的效果
function c76137276.activate(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 连锁发动的魔法卡被送去墓地时，那张卡回到手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_TO_GRAVE)
		e1:SetOperation(c76137276.thop)
		e1:SetReset(RESET_EVENT+0x17a0000)
		re:GetHandler():RegisterEffect(e1)
	end
end
-- 在不受「王家之谷的眠谷」影响的情况下，将该卡加入玩家手牌
function c76137276.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsHasEffect(EFFECT_NECRO_VALLEY) then
		-- 将该卡（连锁发动的魔法卡）加入玩家手牌
		Duel.SendtoHand(e:GetHandler(),tp,REASON_EFFECT)
	end
end
