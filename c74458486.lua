--援護射撃
-- 效果：
-- 对方怪兽攻击自己场上怪兽的场合，伤害步骤时发动。被攻击的自己怪兽的攻击力上升自己场上表侧表示存在的另外1只怪兽的攻击力的数值。
function c74458486.initial_effect(c)
	-- 对方怪兽攻击自己场上怪兽的场合，伤害步骤时发动。被攻击的自己怪兽的攻击力上升自己场上表侧表示存在的另外1只怪兽的攻击力的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(c74458486.condition)
	e1:SetTarget(c74458486.target)
	e1:SetOperation(c74458486.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定：在伤害步骤且伤害计算前，对方怪兽攻击自己场上怪兽时才能发动
function c74458486.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local phase=Duel.GetCurrentPhase()
	-- 判定当前是否处于伤害步骤，且尚未进行伤害计算
	return phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()
		-- 判定攻击怪兽是否由对方控制，且存在被攻击的怪兽（即自己场上的怪兽被攻击）
		and Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()
end
-- 效果对象选择：选择自己场上除被攻击怪兽以外的1只表侧表示怪兽作为对象
function c74458486.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 在发动准备阶段，检查自己场上是否存在除被攻击怪兽以外的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,Duel.GetAttackTarget()) end
	-- 向发动玩家提示选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上除被攻击怪兽以外的1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,Duel.GetAttackTarget())
end
-- 效果处理：使被攻击的自己怪兽的攻击力上升作为对象的怪兽的攻击力数值
function c74458486.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗中被攻击的怪兽
	local at=Duel.GetAttackTarget()
	-- 获取作为效果对象的另外1只怪兽
	local tc=Duel.GetFirstTarget()
	if at:IsFaceup() and at:IsRelateToBattle() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 被攻击的自己怪兽的攻击力上升自己场上表侧表示存在的另外1只怪兽的攻击力的数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(tc:GetAttack())
		at:RegisterEffect(e1)
	end
end
