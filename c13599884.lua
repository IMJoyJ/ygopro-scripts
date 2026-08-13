--鉄のサソリ
-- 效果：
-- 机械族以外的怪兽攻击这张卡的场合，那只怪兽（以对方的回合来数）第3个回合的回合结束时破坏。
function c13599884.initial_effect(c)
	-- 机械族以外的怪兽攻击这张卡的场合，那只怪兽（以对方的回合来数）第3个回合的回合结束时破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13599884,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(c13599884.condition)
	e1:SetOperation(c13599884.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件：对方有机械族以外的怪兽攻击这张卡（本卡为攻击目标）时，才满足触发条件。
function c13599884.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查被攻击对象是否为本卡，且攻击怪兽的种族不是机械族；两者同时满足时条件为真。
	return e:GetHandler()==Duel.GetAttackTarget() and not Duel.GetAttacker():IsRace(RACE_MACHINE)
end
-- 效果处理：给攻击怪兽植入一个不可无效的延迟自毁效果——在每个对方回合结束阶段累加计数，计数达到3时将其破坏。
function c13599884.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取攻击怪兽，作为后续赋予破坏计数效果的载体。
	local tc=Duel.GetAttacker()
	if tc:IsRelateToBattle() then
		-- 那只怪兽（以对方的回合来数）第3个回合的回合结束时破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c13599884.descon)
		e1:SetOperation(c13599884.desop)
		e1:SetLabel(0)
		e1:SetOwnerPlayer(tp)
		tc:RegisterEffect(e1)
	end
end
-- 定义延迟效果的发动条件：仅当进入效果持有者（铁蝎操控者）的对方回合时，结束阶段才进行计数。
function c13599884.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否不是效果所有者，即是否为对方回合；若是则条件成立。
	return e:GetOwnerPlayer()~=Duel.GetTurnPlayer()
end
-- 在满足条件的对方回合结束阶段，将计数加1，并同步至怪兽的回合计数器；计数达到3时破坏该攻击怪兽。
function c13599884.desop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	ct=ct+1
	e:SetLabel(ct)
	e:GetOwner():SetTurnCounter(ct)
	if ct==3 then
		-- 以效果原因破坏携带该效果的怪兽（即之前攻击铁蝎的那只怪兽），实现最终破坏。
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
