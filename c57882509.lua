--弱体化の仮面
-- 效果：
-- ①：以1只攻击怪兽为对象才能发动。那只攻击怪兽的攻击力直到回合结束时下降700。
function c57882509.initial_effect(c)
	-- ①：以1只攻击怪兽为对象才能发动。那只攻击怪兽的攻击力直到回合结束时下降700。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果的发动条件（限制在伤害步骤中的伤害计算前才能发动）
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c57882509.target)
	e1:SetOperation(c57882509.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的对象选择处理，确认攻击怪兽并将其设为效果对象
function c57882509.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前进行攻击的怪兽
	local tc=Duel.GetAttacker()
	if chkc then return chkc==tc end
	if chk==0 then return tc and tc:IsOnField() and tc:IsCanBeEffectTarget(e) end
	-- 将该攻击怪兽注册为当前连锁的效果对象
	Duel.SetTargetCard(tc)
end
-- 效果处理，使作为对象的怪兽在场且关系成立时，其攻击力直到回合结束时下降700
function c57882509.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只攻击怪兽的攻击力直到回合结束时下降700。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-700)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
