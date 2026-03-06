--雷魔神－サンガ
-- 效果：
-- ①：只在这张卡在场上表侧表示存在才有1次，这张卡被攻击的伤害计算时，以1只攻击怪兽为对象才能发动。那只攻击怪兽的攻击力变成0。
function c25955164.initial_effect(c)
	-- 效果原文内容：①：只在这张卡在场上表侧表示存在才有1次，这张卡被攻击的伤害计算时，以1只攻击怪兽为对象才能发动。那只攻击怪兽的攻击力变成0。
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
-- 规则层面作用：判断是否满足发动条件，即当前回合玩家不是使用者且攻击怪兽是该卡本身。
function c25955164.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：判断当前回合玩家不是使用者且攻击怪兽是该卡本身。
	return Duel.GetTurnPlayer()~=tp and Duel.GetAttackTarget()==e:GetHandler()
end
-- 规则层面作用：设置效果目标为当前攻击怪兽。
function c25955164.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查攻击怪兽是否可以成为效果对象。
	if chk==0 then return Duel.GetAttacker():IsCanBeEffectTarget(e) end
	-- 规则层面作用：将当前攻击怪兽设置为效果对象。
	Duel.SetTargetCard(Duel.GetAttacker())
end
-- 规则层面作用：执行效果操作，将目标怪兽攻击力设为0。
function c25955164.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁中的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 效果原文内容：那只攻击怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(0)
		tc:RegisterEffect(e1)
	end
end
