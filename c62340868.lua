--風魔神－ヒューガ
-- 效果：
-- ①：只在这张卡在场上表侧表示存在才有1次，这张卡被攻击的伤害计算时，以1只攻击怪兽为对象才能发动。那只攻击怪兽的攻击力变成0。
function c62340868.initial_effect(c)
	-- ①：只在这张卡在场上表侧表示存在才有1次，这张卡被攻击的伤害计算时，以1只攻击怪兽为对象才能发动。那只攻击怪兽的攻击力变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62340868,0))  --"攻击变成0"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetCountLimit(1)
	e1:SetCondition(c62340868.condition)
	e1:SetTarget(c62340868.target)
	e1:SetOperation(c62340868.operation)
	c:RegisterEffect(e1)
end
-- 判断是否满足‘这张卡被攻击的伤害计算时’的发动条件
function c62340868.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为对手回合，且自身是否为被攻击的怪兽
	return Duel.GetTurnPlayer()~=tp and Duel.GetAttackTarget()==e:GetHandler()
end
-- 定义效果的对象选择与发动检查函数
function c62340868.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认攻击怪兽是否可以作为效果对象
	if chk==0 then return Duel.GetAttacker():IsCanBeEffectTarget(e) end
	-- 将攻击怪兽确认为效果的对象
	Duel.SetTargetCard(Duel.GetAttacker())
end
-- 定义效果处理（使攻击怪兽攻击力变成0）的执行函数
function c62340868.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取之前选定为效果对象的攻击怪兽
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
