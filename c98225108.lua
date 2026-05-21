--レオンタウロス
-- 效果：
-- ①：这张卡和通常怪兽以外的怪兽进行战斗的伤害步骤内，这张卡的攻击力上升500。
function c98225108.initial_effect(c)
	-- ①：这张卡和通常怪兽以外的怪兽进行战斗的伤害步骤内，这张卡的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(c98225108.condtion)
	e1:SetValue(500)
	c:RegisterEffect(e1)
end
-- 判断当前是否处于伤害步骤（或伤害计算时），且这张卡的战斗对象存在且不为通常怪兽
function c98225108.condtion(e)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	local bc=e:GetHandler():GetBattleTarget()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) and bc and not bc:IsType(TYPE_NORMAL)
end
