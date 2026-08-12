--トラップ・スタン
-- 效果：
-- ①：这个回合，这张卡以外的场上的陷阱卡的效果无效化。
function c59616123.initial_effect(c)
	-- ①：这个回合，这张卡以外的场上的陷阱卡的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c59616123.activate)
	c:RegisterEffect(e1)
end
-- 卡片发动时的效果处理：注册使场上其他陷阱卡效果无效的三个全局效果，持续到回合结束
function c59616123.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ①：这个回合，这张卡以外的场上的陷阱卡的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1:SetTarget(c59616123.distarget)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向全局注册无效魔陷区陷阱卡常驻效果的效果
	Duel.RegisterEffect(e1,tp)
	-- ①：这个回合，这张卡以外的场上的陷阱卡的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetOperation(c59616123.disoperation)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 向全局注册在连锁处理时使场上发动的陷阱卡效果无效的效果
	Duel.RegisterEffect(e2,tp)
	-- ①：这个回合，这张卡以外的场上的陷阱卡的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c59616123.distarget)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 向全局注册无效怪兽区陷阱怪兽效果的效果
	Duel.RegisterEffect(e3,tp)
end
-- 过滤条件：非这张卡本身且是陷阱卡的卡片
function c59616123.distarget(e,c)
	return c~=e:GetHandler() and c:IsType(TYPE_TRAP)
end
-- 连锁处理时的无效操作：如果连锁发生位置在魔陷区且是陷阱卡的效果，则使该连锁的效果无效
function c59616123.disoperation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前处理的连锁的发动位置
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if tl==LOCATION_SZONE and re:IsActiveType(TYPE_TRAP) then
		-- 使该连锁的效果无效
		Duel.NegateEffect(ev)
	end
end
