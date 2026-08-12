--ペンデュラム・モラトリアム
-- 效果：
-- ①：这个回合，自己以及对方的灵摆区域的卡不会被对方的效果破坏，以灵摆区域的卡为对象的对方发动的效果无效化。
function c60434189.initial_effect(c)
	-- ①：这个回合，自己以及对方的灵摆区域的卡不会被对方的效果破坏，以灵摆区域的卡为对象的对方发动的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c60434189.activate)
	c:RegisterEffect(e1)
end
-- 魔法卡发动时的效果处理：在全局注册本回合内“灵摆区的卡不会被对方效果破坏”和“以灵摆区的卡为对象的对方效果无效化”的两个效果。
function c60434189.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合，自己以及对方的灵摆区域的卡不会被对方的效果破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_PZONE,LOCATION_PZONE)
	-- 设置抗性类型为不会被对方的效果破坏。
	e1:SetValue(aux.indoval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不会被对方效果破坏的永续效果注册给全局环境。
	Duel.RegisterEffect(e1,tp)
	-- 以灵摆区域的卡为对象的对方发动的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetCondition(c60434189.discon)
	e2:SetOperation(c60434189.disop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将用于无效对方效果的事件触发效果注册给全局环境。
	Duel.RegisterEffect(e2,tp)
end
-- 过滤函数：检查卡片当前是否在灵摆区域。
function c60434189.indfilter(c)
	return c:IsLocation(LOCATION_PZONE)
end
-- 判断是否满足无效条件：对方发动的效果，且该效果的对象中包含灵摆区域的卡。
function c60434189.discon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的对象卡片组。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(c60434189.indfilter,1,nil) and ep~=tp
end
-- 执行无效化操作：使该连锁的效果无效。
function c60434189.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前处理中的连锁效果无效。
	Duel.NegateEffect(ev)
end
