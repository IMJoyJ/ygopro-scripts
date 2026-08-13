--砂塵の結界
-- 效果：
-- 场上所有以表侧表示存在的通常怪兽不受对方魔法卡效果的影响。在这张卡发动后的第2个自己的准备阶段时，这张卡被破坏。
function c31476755.initial_effect(c)
	-- 在这张卡发动后的第2个自己的准备阶段时，这张卡被破坏。
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
	-- 将免疫效果的适用对象限定为通常怪兽（引擎中里侧怪兽不满足通常怪兽类型判断，实际覆盖场上表侧表示的通常怪兽）。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_NORMAL))
	e2:SetValue(c31476755.efilter)
	c:RegisterEffect(e2)
end
-- 发动效果处理：将这张卡的回合计数器重置为0，并给自身注册一个不可被无效的连续效果，用于在准备阶段逐步计数并在第2次自己的准备阶段破坏这张卡。
function c31476755.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	c:SetTurnCounter(0)
	-- 在这张卡发动后的第2个自己的准备阶段时，这张卡被破坏。
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
-- 自毁计数效果的发动条件：仅在当前回合玩家为这张卡的控制者（即自己的准备阶段）时才执行。
function c31476755.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否就是这张卡的控制者，以此限定在自己的准备阶段触发。
	return tp==Duel.GetTurnPlayer()
end
-- 自毁计数效果的处理：将回合计数器加1；当计数达到2时，破坏这张卡。
function c31476755.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==2 then
		-- 以规则原因破坏这张卡（不触发免疫、代破效果，且无视“不能破坏”）。
		Duel.Destroy(c,REASON_RULE)
	end
end
-- 免疫判定函数：检查对方发动的效果是否为魔法卡效果；若是，则我方通常怪兽不受其影响。
function c31476755.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActiveType(TYPE_SPELL)
end
