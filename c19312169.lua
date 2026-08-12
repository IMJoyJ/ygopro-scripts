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
	-- 场上所有陷阱卡的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_HAND+LOCATION_SZONE,LOCATION_HAND+LOCATION_SZONE)
	e3:SetTarget(c19312169.distg)
	c:RegisterEffect(e3)
	-- 陷阱卡不能发动
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e4:SetTarget(c19312169.distg)
	c:RegisterEffect(e4)
	-- 陷阱卡不能发动
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
-- 用于检测场上是否存在「封印师 明晴」的过滤函数
function c19312169.filter(c)
	return c:IsFaceup() and c:IsCode(2468169)
end
-- 判断是否满足发动条件，即自己场上是否存在「封印师 明晴」
function c19312169.actcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张「封印师 明晴」
	return Duel.IsExistingMatchingCard(c19312169.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 判断是否满足破坏条件，即自己场上不存在「封印师 明晴」
function c19312169.descon(e)
	-- 检查自己场上是否不存在「封印师 明晴」
	return not Duel.IsExistingMatchingCard(c19312169.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 用于筛选陷阱卡的过滤函数
function c19312169.distg(e,c)
	return c:IsType(TYPE_TRAP)
end
-- 连锁处理时，若触发的是陷阱卡的效果，则使其无效
function c19312169.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的触发位置
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if tl==LOCATION_SZONE and re:IsActiveType(TYPE_TRAP) then
		-- 使当前连锁的效果无效
		Duel.NegateEffect(ev)
	end
end
