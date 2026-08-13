--雷魔神－サンガ
-- 效果：
-- ①：只在这张卡在场上表侧表示存在才有1次，这张卡被攻击的伤害计算时，以1只攻击怪兽为对象才能发动。那只攻击怪兽的攻击力变成0。
function c25955164.initial_effect(c)
	-- ①：只在这张卡在场上表侧表示存在才有1次，这张卡被攻击的伤害计算时，以1只攻击怪兽为对象才能发动。那只攻击怪兽的攻击力变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25955164,0))  --"攻击变成0"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetCountLimit(1)
	e1:SetCondition(c25955164.condition)
	e1:SetTarget(c25955164.target)
	e1:SetOperation(c25955164.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件判断：必须是对方回合，且这张卡是被攻击的怪兽（即伤害计算时这张卡作为攻击目标）。
function c25955164.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家不是这张卡的控制者，且攻击目标就是这张卡自身，满足发动条件。
	return Duel.GetTurnPlayer()~=tp and Duel.GetAttackTarget()==e:GetHandler()
end
-- 效果发动时的取对象处理：选择1只攻击怪兽作为对象，并设置目标。
function c25955164.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点检查：攻击怪兽能够成为该效果的对象，则满足发动条件。
	if chk==0 then return Duel.GetAttacker():IsCanBeEffectTarget(e) end
	-- 将攻击怪兽设置为当前连锁的效果对象。
	Duel.SetTargetCard(Duel.GetAttacker())
end
-- 效果处理：将对象怪兽的攻击力变成0，持续到伤害计算阶段结束。
function c25955164.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的那只攻击怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 那只攻击怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(0)
		tc:RegisterEffect(e1)
	end
end
