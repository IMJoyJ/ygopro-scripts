--ドゥーブルパッセ
-- 效果：
-- ①：对方怪兽向自己场上的表侧攻击表示怪兽攻击宣言时才能发动。给与对方为攻击对象怪兽的攻击力数值的伤害，那只对方怪兽的攻击变成向自己的直接攻击。那只自己怪兽在下次的自己回合可以直接攻击。
function c79997591.initial_effect(c)
	-- ①：对方怪兽向自己场上的表侧攻击表示怪兽攻击宣言时才能发动。给与对方为攻击对象怪兽的攻击力数值的伤害，那只对方怪兽的攻击变成向自己的直接攻击。那只自己怪兽在下次的自己回合可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79997591,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c79997591.cbcon)
	e1:SetTarget(c79997591.cbtg)
	e1:SetOperation(c79997591.cbop)
	c:RegisterEffect(e1)
end
-- 判定发动条件：检查攻击对象是否为自己场上的表侧攻击表示怪兽
function c79997591.cbcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击目标怪兽
	local bt=Duel.GetAttackTarget()
	return bt and bt:IsLocation(LOCATION_MZONE) and bt:IsPosition(POS_FACEUP_ATTACK) and bt:IsControler(tp)
end
-- 判定效果发动的靶向：检查攻击怪兽是否可以进行直接攻击
function c79997591.cbtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动条件检查时，确认攻击怪兽没有受到‘不能直接攻击’的效果影响
	if chk==0 then return not Duel.GetAttacker():IsHasEffect(EFFECT_CANNOT_DIRECT_ATTACK) end
end
-- 执行效果：给与对方伤害，将攻击变更为直接攻击，并赋予自己怪兽下次自己回合直接攻击的效果
function c79997591.cbop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击的怪兽
	local at=Duel.GetAttacker()
	-- 获取当前被攻击的怪兽
	local bt=Duel.GetAttackTarget()
	if not (bt:IsRelateToBattle() and bt:IsControler(tp)) then return end
	-- 在攻击怪兽可攻击且未被取消攻击的状态下，给与对方等同于被攻击怪兽攻击力数值的伤害
	if at:IsAttackable() and not at:IsStatus(STATUS_ATTACK_CANCELED) and Duel.Damage(1-tp,bt:GetAttack(),REASON_EFFECT)>0 then
		-- 将攻击对象变更为直接攻击
		Duel.ChangeAttackTarget(nil)
	end
	-- 那只自己怪兽在下次的自己回合可以直接攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN)
	bt:RegisterEffect(e1)
end
