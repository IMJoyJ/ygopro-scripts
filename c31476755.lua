--砂塵の結界
-- 效果：
-- 场上所有以表侧表示存在的通常怪兽不受对方魔法卡效果的影响。在这张卡发动后的第2个自己的准备阶段时，这张卡被破坏。
function c31476755.initial_effect(c)
	-- 场上所有以表侧表示存在的通常怪兽不受对方魔法卡效果的影响。在这张卡发动后的第2个自己的准备阶段时，这张卡被破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c31476755.target)
	c:RegisterEffect(e1)
	-- 场上所有以表侧表示存在的通常怪兽不受对方魔法卡效果的影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果目标为场上所有表侧表示的通常怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_NORMAL))
	e2:SetValue(c31476755.efilter)
	c:RegisterEffect(e2)
end
-- 设置此卡发动时的处理逻辑，包括初始化回合计数器并注册准备阶段破坏效果
function c31476755.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	c:SetTurnCounter(0)
	-- 注册一个在准备阶段触发的持续效果，用于检测是否到达第2个准备阶段
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c31476755.descon)
	e1:SetOperation(c31476755.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
	c:RegisterEffect(e1)
end
-- 判断是否为当前回合玩家触发的准备阶段
function c31476755.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者
	return tp==Duel.GetTurnPlayer()
end
-- 准备阶段触发时的处理函数，用于增加回合计数器并判断是否达到破坏条件
function c31476755.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==2 then
		-- 满足条件时将此卡以规则破坏
		Duel.Destroy(c,REASON_RULE)
	end
end
-- 过滤效果，用于判断是否对魔法卡效果免疫
function c31476755.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActiveType(TYPE_SPELL)
end
