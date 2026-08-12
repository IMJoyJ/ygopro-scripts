--ハーフ・カウンター
-- 效果：
-- 自己场上存在的怪兽被攻击的场合，那次伤害计算时才能发动。成为攻击对象的1只自己怪兽的攻击力直到结束阶段时上升攻击怪兽的原本攻击力一半的数值。
function c6799227.initial_effect(c)
	-- 自己场上存在的怪兽被攻击的场合，那次伤害计算时才能发动。成为攻击对象的1只自己怪兽的攻击力直到结束阶段时上升攻击怪兽的原本攻击力一半的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c6799227.condition)
	e1:SetTarget(c6799227.target)
	e1:SetOperation(c6799227.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：判断当前被攻击的怪兽是否存在且控制权属于自己
function c6799227.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击对象（被攻击的怪兽）
	local t=Duel.GetAttackTarget()
	return t and t:IsControler(tp)
end
-- 效果的目标选择与合法性检测：将成为攻击对象的自己怪兽设为效果对象
function c6799227.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前的攻击对象
	local tg=Duel.GetAttackTarget()
	if chkc then return chkc==tg end
	-- 在发动阶段（chk==0）检查攻击怪兽是否在场，且攻击对象是否能成为效果对象
	if chk==0 then return Duel.GetAttacker():IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将攻击对象怪兽注册为本效果的目标对象
	Duel.SetTargetCard(tg)
end
-- 效果处理：使成为攻击对象的自己怪兽的攻击力直到结束阶段时上升
function c6799227.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本效果的目标对象（即被攻击的自己怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 获取攻击怪兽的原本攻击力
		local atk=Duel.GetAttacker():GetBaseAttack()
		-- 攻击力直到结束阶段时上升攻击怪兽的原本攻击力一半的数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(math.ceil(atk/2))
		tc:RegisterEffect(e1)
	end
end
