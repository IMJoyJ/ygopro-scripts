--九十九スラッシュ
-- 效果：
-- 「九十九斩」在1回合只能发动1张。
-- ①：自己怪兽向比那只怪兽攻击力高的怪兽攻击的伤害计算时才能发动。那只进行战斗的自己怪兽的攻击力只在那次伤害计算时上升自己和对方的基本分差的数值。
function c25334372.initial_effect(c)
	-- 「九十九斩」在1回合只能发动1张。①：自己怪兽向比那只怪兽攻击力高的怪兽攻击的伤害计算时才能发动。那只进行战斗的自己怪兽的攻击力只在那次伤害计算时上升自己和对方的基本分差的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCountLimit(1,25334372+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c25334372.atkcon)
	e1:SetOperation(c25334372.atkop)
	c:RegisterEffect(e1)
end
-- 伤害计算时的发动条件判断：获取攻击怪兽及攻击对象，检查攻击怪兽属于己方、攻击力低于攻击对象且双方基本分不同，满足条件时效果才可发动。
function c25334372.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取攻击对象怪兽（不存在攻击对象时无法发动）。
	local d=Duel.GetAttackTarget()
	if not d then return false end
	-- 返回发动条件是否成立：攻击怪兽为己方控制、其攻击力小于攻击对象，且双方基本分不相等。
	return a:IsControler(tp) and a:GetAttack()<d:GetAttack() and Duel.GetLP(tp)~=Duel.GetLP(1-tp)
end
-- 效果处理：获取进行战斗的我方攻击怪兽，若其仍表侧表示且与本次战斗相关，则计算双方基本分之差绝对值，将其作为攻击力上升数值赋予该怪兽，并仅在本次伤害计算时生效。
function c25334372.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行战斗的我方攻击怪兽。
	local c=Duel.GetAttacker()
	if c:IsFaceup() and c:IsRelateToBattle() then
		-- 计算双方基本分之差的绝对值，作为攻击力上升的数值。
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
