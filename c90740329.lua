--挑発
-- 效果：
-- 对方回合的主要阶段一，选择自己场上的1只怪兽才能发动。只要选择怪兽在场上存在，对方这个回合攻击的场合，必须以选择的怪兽为攻击对象。
function c90740329.initial_effect(c)
	-- 对方回合的主要阶段一，选择自己场上的1只怪兽才能发动。只要选择怪兽在场上存在，对方这个回合攻击的场合，必须以选择的怪兽为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(c90740329.condition)
	e1:SetTarget(c90740329.target)
	e1:SetOperation(c90740329.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定
function c90740329.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为对方回合的主要阶段一
	return Duel.GetTurnPlayer()~=tp and Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 效果发动时的对象选择处理
function c90740329.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 检查自己场上是否存在可以作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择攻击的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACKTARGET)  --"请选择攻击的对象"
	-- 选择自己场上的一只怪兽作为效果对象
	Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果发动时的处理（注册强制攻击效果）
function c90740329.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local fid=tc:GetRealFieldID()
		-- 只要选择怪兽在场上存在，对方这个回合攻击的场合，必须以选择的怪兽为攻击对象。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
		e2:SetTargetRange(0,LOCATION_MZONE)
		e2:SetValue(c90740329.atklimit)
		e2:SetLabel(fid)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 将强制攻击效果注册给全局环境
		Duel.RegisterEffect(e2,tp)
	end
end
-- 限制攻击目标的判定函数，使对方怪兽必须以选择的怪兽为攻击对象
function c90740329.atklimit(e,c)
	return c:GetRealFieldID()==e:GetLabel()
end
