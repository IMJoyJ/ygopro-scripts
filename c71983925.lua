--魔法封印の呪符
-- 效果：
-- 这张卡仅当自己场上存在「封印师 明晴」时才能发动。这张卡在场上存在时，魔法卡不能发动，场上所有魔法卡的效果无效化。「封印师 明晴」不在自己场上存在时，这张卡破坏。
function c71983925.initial_effect(c)
	-- 这张卡仅当自己场上存在「封印师 明晴」时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c71983925.actcon)
	c:RegisterEffect(e1)
	-- 「封印师 明晴」不在自己场上存在时，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(c71983925.descon)
	c:RegisterEffect(e2)
	-- 这张卡在场上存在时，魔法卡不能发动
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_HAND+LOCATION_SZONE,LOCATION_HAND+LOCATION_SZONE)
	e3:SetTarget(c71983925.distg)
	c:RegisterEffect(e3)
	-- 场上所有魔法卡的效果无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e4:SetTarget(c71983925.distg)
	c:RegisterEffect(e4)
	-- 场上所有魔法卡的效果无效化。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAIN_SOLVING)
	e5:SetRange(LOCATION_SZONE)
	e5:SetOperation(c71983925.disop)
	c:RegisterEffect(e5)
end
-- 过滤函数：检查卡片是否为表侧表示的「封印师 明晴」
function c71983925.filter(c)
	return c:IsFaceup() and c:IsCode(2468169)
end
-- 发动条件：自己场上存在表侧表示的「封印师 明晴」
function c71983925.actcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区是否存在至少1张表侧表示的「封印师 明晴」
	return Duel.IsExistingMatchingCard(c71983925.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 自我破坏条件：自己场上不存在表侧表示的「封印师 明晴」
function c71983925.descon(e)
	-- 检查自己怪兽区是否不存在表侧表示的「封印师 明晴」
	return not Duel.IsExistingMatchingCard(c71983925.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 目标过滤：检查卡片是否为魔法卡
function c71983925.distg(e,c)
	return c:IsType(TYPE_SPELL)
end
-- 效果处理：若在魔陷区发动的魔法卡效果在进行连锁处理，则将其效果无效
function c71983925.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在处理的连锁的发动位置
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if bit.band(tl,LOCATION_SZONE)~=0 and re:IsActiveType(TYPE_SPELL) then
		-- 无效该连锁的效果
		Duel.NegateEffect(ev)
	end
end
