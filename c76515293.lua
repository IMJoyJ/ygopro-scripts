--心鎮壷
-- 效果：
-- 选择场上盖放的2张魔法·陷阱卡才能发动。只要这张卡在场上存在，选择的魔法·陷阱卡不能发动。
function c76515293.initial_effect(c)
	-- 选择场上盖放的2张魔法·陷阱卡才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c76515293.target)
	e1:SetOperation(c76515293.operation)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，选择的魔法·陷阱卡不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_TARGET)
	e2:SetCode(EFFECT_CANNOT_TRIGGER)
	e2:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e2)
end
-- 发动时的效果处理，检查并选择场上盖放的2张魔法·陷阱卡作为对象
function c76515293.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsFacedown() end
	-- 在发动准备阶段，检查场上是否存在至少2张除这张卡以外的里侧表示的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,LOCATION_SZONE,LOCATION_SZONE,2,e:GetHandler()) end
	-- 向发动玩家发送提示信息，提示其选择里侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)  --"请选择里侧表示的卡"
	-- 让发动玩家选择场上2张里侧表示的魔法·陷阱卡作为效果的对象
	Duel.SelectTarget(tp,Card.IsFacedown,tp,LOCATION_SZONE,LOCATION_SZONE,2,2,e:GetHandler())
end
-- 发动成功时的效果处理，将选择的卡作为这张卡的永续对象
function c76515293.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	while tc do
		if c:IsRelateToEffect(e) and tc:IsFacedown() and tc:IsRelateToEffect(e) then
			c:SetCardTarget(tc)
		end
		tc=g:GetNext()
	end
end
