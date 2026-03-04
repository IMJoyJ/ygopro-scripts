--鉄のサソリ
-- 效果：
-- 机械族以外的怪兽攻击这张卡的场合，那只怪兽（以对方的回合来数）第3个回合的回合结束时破坏。
function c13599884.initial_effect(c)
	-- 诱发必发效果，当此卡成为攻击怪兽的攻击目标且攻击怪兽不是机械族时发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13599884,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(c13599884.condition)
	e1:SetOperation(c13599884.operation)
	c:RegisterEffect(e1)
end
-- 效果条件函数
function c13599884.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击怪兽是否不是机械族
	return e:GetHandler()==Duel.GetAttackTarget() and not Duel.GetAttacker():IsRace(RACE_MACHINE)
end
-- 效果处理函数
function c13599884.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取此次战斗的攻击怪兽
	local tc=Duel.GetAttacker()
	if tc:IsRelateToBattle() then
		-- 创建一个场上的持续效果，用于在回合结束时检查并破坏攻击怪兽
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
-- 破坏判定条件函数
function c13599884.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否与效果拥有者不同
	return e:GetOwnerPlayer()~=Duel.GetTurnPlayer()
end
-- 破坏处理函数
function c13599884.desop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	ct=ct+1
	e:SetLabel(ct)
	e:GetOwner():SetTurnCounter(ct)
	if ct==3 then
		-- 将该怪兽以效果原因破坏
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
