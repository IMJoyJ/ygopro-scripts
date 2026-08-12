--リチュアルバスター
-- 效果：
-- ①：自己或者对方仪式召唤成功时才能发动。直到下次的自己回合的准备阶段，对方不能作魔法·陷阱卡的发动以及那个效果的发动。
function c54094821.initial_effect(c)
	-- ①：自己或者对方仪式召唤成功时才能发动。直到下次的自己回合的准备阶段，对方不能作魔法·陷阱卡的发动以及那个效果的发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c54094821.condition)
	e1:SetOperation(c54094821.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：检查怪兽是否为仪式召唤成功
function c54094821.cfilter(c)
	return c:IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 发动条件：检查当前特殊召唤的怪兽中是否存在仪式召唤成功的怪兽
function c54094821.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c54094821.cfilter,1,nil)
end
-- 效果处理：在全局注册一个限制对方发动魔法、陷阱卡及其效果的玩家效果，并根据当前回合和阶段计算重置时间
function c54094821.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 直到下次的自己回合的准备阶段，对方不能作魔法·陷阱卡的发动以及那个效果的发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c54094821.aclimit)
	-- 判断当前是否为自己回合的准备阶段或更早的阶段，用于确定效果重置的准备阶段计数
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()<=PHASE_STANDBY then
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
	end
	-- 将限制对方发动的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制发动条件：判断发动的卡或效果是否为魔法卡或陷阱卡
function c54094821.aclimit(e,re,tp)
	return re:GetHandler():IsType(TYPE_SPELL+TYPE_TRAP)
end
