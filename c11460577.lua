--エトワール・サイバー
-- 效果：
-- ①：这张卡直接攻击的伤害步骤内，攻击力上升500。
function c11460577.initial_effect(c)
	-- ①：这张卡直接攻击的伤害步骤内，攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(c11460577.condtion)
	e1:SetValue(500)
	c:RegisterEffect(e1)
end
-- 效果条件：仅在直接攻击且当前处于伤害步骤（伤害步骤或伤害计算时）时，该效果才适用。
function c11460577.condtion(e)
	-- 获取当前战斗阶段，用于判断是否处于伤害步骤内。
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
		-- 判断本次战斗攻击者为这张卡自身，且攻击目标为空，即进行直接攻击。
		and Duel.GetAttacker()==e:GetHandler() and Duel.GetAttackTarget()==nil
end
