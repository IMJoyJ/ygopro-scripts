--トラップ・キャプチャー
-- 效果：
-- 自己把陷阱卡发动时，丢弃1张手卡连锁发动。连锁发动的陷阱卡被送去墓地时，那张卡回到手卡。
function c2122975.initial_effect(c)
	-- 创建陷阱卡的发动效果，监听连锁发动事件
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c2122975.condition)
	e1:SetCost(c2122975.cost)
	e1:SetOperation(c2122975.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时，确认是自己发动的魔法或陷阱卡
function c2122975.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP)
end
-- 发动时丢弃1张手卡作为代价
function c2122975.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃手卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃1张手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 连锁发动的陷阱卡被送去墓地时，注册返回手卡的效果
function c2122975.activate(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 注册一个在卡送去墓地时触发的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_TO_GRAVE)
		e1:SetOperation(c2122975.thop)
		e1:SetReset(RESET_EVENT+0x17a0000)
		re:GetHandler():RegisterEffect(e1)
	end
end
-- 当卡被送去墓地时，若未被王家长眠之谷效果影响，则送回手卡
function c2122975.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsHasEffect(EFFECT_NECRO_VALLEY) then
		-- 将卡送回手卡
		Duel.SendtoHand(e:GetHandler(),tp,REASON_EFFECT)
	end
end
