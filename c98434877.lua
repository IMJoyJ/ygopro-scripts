--水魔神－スーガ
-- 效果：
-- ①：只在这张卡在场上表侧表示存在才有1次，这张卡被攻击的伤害计算时，以1只攻击怪兽为对象才能发动。那只攻击怪兽的攻击力变成0。
function c98434877.initial_effect(c)
	-- ①：只在这张卡在场上表侧表示存在才有1次，这张卡被攻击的伤害计算时，以1只攻击怪兽为对象才能发动。那只攻击怪兽的攻击力变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98434877,0))  --"攻击变成0"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetCountLimit(1)
	e1:SetCondition(c98434877.condition)
	e1:SetTarget(c98434877.target)
	e1:SetOperation(c98434877.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件：判断是否满足在被攻击的伤害计算时发动的条件
function c98434877.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家不是自身（即对方回合），且被攻击的怪兽是这张卡自身
	return Duel.GetTurnPlayer()~=tp and Duel.GetAttackTarget()==e:GetHandler()
end
-- 效果发动目标：验证并指定攻击怪兽为效果对象
function c98434877.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，判断攻击怪兽是否可以成为该效果的对象
	if chk==0 then return Duel.GetAttacker():IsCanBeEffectTarget(e) end
	-- 将攻击怪兽注册为当前效果的对象
	Duel.SetTargetCard(Duel.GetAttacker())
end
-- 效果运行空间：在伤害计算时将作为对象的攻击怪兽的攻击力变为0
function c98434877.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段指定的第一个效果对象（即攻击怪兽）
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
