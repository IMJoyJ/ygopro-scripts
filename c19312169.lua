--罠封印の呪符
-- 效果：
-- 这张卡仅当自己场上存在「封印师 明晴」时才能发动。这张卡在场上存在时，陷阱卡不能发动，场上所有陷阱卡的效果无效化。「封印师 明晴」不在自己场上存在时，这张卡破坏。
function c19312169.initial_effect(c)
	-- 这张卡仅当自己场上存在「封印师 明晴」时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c19312169.actcon)
	c:RegisterEffect(e1)
	-- 「封印师 明晴」不在自己场上存在时，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(c19312169.descon)
	c:RegisterEffect(e2)
	-- 这张卡在场上存在时，陷阱卡不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_HAND+LOCATION_SZONE,LOCATION_HAND+LOCATION_SZONE)
	e3:SetTarget(c19312169.distg)
	c:RegisterEffect(e3)
	-- 场上所有陷阱卡的效果无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e4:SetTarget(c19312169.distg)
	c:RegisterEffect(e4)
	-- 场上所有陷阱卡的效果无效化。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAIN_SOLVING)
	e5:SetRange(LOCATION_SZONE)
	e5:SetOperation(c19312169.disop)
	c:RegisterEffect(e5)
	-- 场上所有陷阱卡的效果无效化。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	e6:SetRange(LOCATION_SZONE)
	e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e6:SetTarget(c19312169.distg)
	c:RegisterEffect(e6)
end
-- 过滤函数：判断一张卡是否为表侧表示且卡号为2468169（封印师 明晴），用于检索自己场上的明晴。
function c19312169.filter(c)
	return c:IsFaceup() and c:IsCode(2468169)
end
-- 发动条件判定：检查自己场上是否存在表侧表示的「封印师 明晴」，作为发动效果的资格条件。
function c19312169.actcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定以当前玩家tp视角，自己怪兽区是否存在至少1张满足filter条件的明晴。
	return Duel.IsExistingMatchingCard(c19312169.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 自我破坏条件判定：检查自己场上是否不存在表侧表示的「封印师 明晴」，若不存在则满足破坏条件。
function c19312169.descon(e)
	-- 取反判定：检查自己场上不存在明晴，作为触发自我破坏的依据。
	return not Duel.IsExistingMatchingCard(c19312169.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 目标筛选函数：判断目标卡是否为陷阱卡，用于限定受本卡效果影响的卡片。
function c19312169.distg(e,c)
	return c:IsType(TYPE_TRAP)
end
-- 连锁处理时的无效操作：取得当前连锁的发生位置，若为魔陷区且发动者为陷阱卡，则无效该连锁。
function c19312169.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁ev的发生位置，用于判断是否满足无效条件。
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if tl==LOCATION_SZONE and re:IsActiveType(TYPE_TRAP) then
		-- 使指定连锁的效果无效化，即无效该陷阱卡的发动与效果处理。
		Duel.NegateEffect(ev)
	end
end
