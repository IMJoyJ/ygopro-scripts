--九十九スラッシュ
-- 效果：
-- 「九十九斩」在1回合只能发动1张。
-- ①：自己怪兽向比那只怪兽攻击力高的怪兽攻击的伤害计算时才能发动。那只进行战斗的自己怪兽的攻击力只在那次伤害计算时上升自己和对方的基本分差的数值。
function c25334372.initial_effect(c)
	-- ①：自己怪兽向比那只怪兽攻击力高的怪兽攻击的伤害计算时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCountLimit(1,25334372+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c25334372.atkcon)
	e1:SetOperation(c25334372.atkop)
	c:RegisterEffect(e1)
end
-- 检查攻击怪兽是否为自己的怪兽，且其攻击力小于攻击目标怪兽的攻击力，且双方基本分不同。
function c25334372.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取此次战斗的攻击目标怪兽
	local d=Duel.GetAttackTarget()
	if not d then return false end
	-- 返回攻击怪兽为我方、攻击力小于目标、且双方基本分不同的条件判断结果
	return a:IsControler(tp) and a:GetAttack()<d:GetAttack() and Duel.GetLP(tp)~=Duel.GetLP(1-tp)
end
-- 处理攻击力变化效果，使攻击怪兽在伤害计算时攻击力上升双方基本分差值
function c25334372.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗的攻击怪兽
	local c=Duel.GetAttacker()
	if c:IsFaceup() and c:IsRelateToBattle() then
		-- 计算双方基本分差的绝对值作为攻击力上升数值
		local atk=math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp))
		-- 那只进行战斗的自己怪兽的攻击力只在那次伤害计算时上升自己和对方的基本分差的数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(atk)
		c:RegisterEffect(e1)
	end
end
