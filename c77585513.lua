--人造人間－サイコ・ショッカー
-- 效果：
-- ①：只要这张卡在怪兽区域存在，双方不能把场上的陷阱卡的效果发动，场上的陷阱卡的效果无效化。
function c77585513.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，双方不能把场上的陷阱卡的效果发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TRIGGER)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_SZONE,LOCATION_HAND+LOCATION_SZONE)
	e1:SetCondition(c77585513.condition1)
	e1:SetTarget(c77585513.distg)
	c:RegisterEffect(e1)
	-- 场上的陷阱卡的效果无效化
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e2:SetCondition(c77585513.condition1)
	e2:SetTarget(c77585513.distg)
	c:RegisterEffect(e2)
	-- 场上的陷阱卡的效果无效化
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c77585513.discon1)
	e3:SetOperation(c77585513.disop1)
	c:RegisterEffect(e3)
	-- 场上的陷阱卡的效果无效化
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetCondition(c77585513.condition1)
	e4:SetTarget(c77585513.distg)
	c:RegisterEffect(e4)
	local e5=e1:Clone()
	e5:SetTargetRange(0,LOCATION_HAND+LOCATION_SZONE)
	e5:SetCondition(c77585513.condition2)
	c:RegisterEffect(e5)
	local e6=e2:Clone()
	e6:SetTargetRange(0,LOCATION_SZONE)
	e6:SetCondition(c77585513.condition2)
	c:RegisterEffect(e6)
	local e7=e3:Clone()
	e7:SetCondition(c77585513.discon2)
	e7:SetOperation(c77585513.disop2)
	c:RegisterEffect(e7)
	local e8=e4:Clone()
	e8:SetTargetRange(0,LOCATION_MZONE)
	e8:SetCondition(c77585513.condition2)
	c:RegisterEffect(e8)
end
-- 检查自身是否未装备「电脑增幅器」（若未装备，则适用影响双方的常规效果）
function c77585513.condition1(e)
	return not e:GetHandler():IsHasEffect(303660)
end
-- 过滤出陷阱卡作为效果影响的对象
function c77585513.distg(e,c)
	return c:IsType(TYPE_TRAP)
end
-- 连锁处理时，检查自身是否未装备「电脑增幅器」
function c77585513.discon1(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsHasEffect(303660)
end
-- 在连锁处理时，若发动位置在魔法与陷阱区域且为陷阱卡的效果，则将其效果无效
function c77585513.disop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前处理的连锁的发动位置
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if tl==LOCATION_SZONE and re:IsActiveType(TYPE_TRAP) then
		-- 使该连锁的效果无效
		Duel.NegateEffect(ev)
	end
end
-- 检查自身是否装备了「电脑增幅器」（若装备，则适用仅影响对方的效果）
function c77585513.condition2(e)
	return e:GetHandler():IsHasEffect(303660)
end
-- 连锁处理时，检查自身是否装备了「电脑增幅器」
function c77585513.discon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsHasEffect(303660)
end
-- 在连锁处理时，若对方在魔法与陷阱区域发动陷阱卡的效果，则将其效果无效
function c77585513.disop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前处理的连锁的发动玩家和发动位置
	local p,tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	if p==1-e:GetHandlerPlayer() and tl==LOCATION_SZONE and re:IsActiveType(TYPE_TRAP) then
		-- 使该连锁的效果无效
		Duel.NegateEffect(ev)
	end
end
