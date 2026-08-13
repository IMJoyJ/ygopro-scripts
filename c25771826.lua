--A・O・J ガラドホルグ
-- 效果：
-- 这张卡和光属性怪兽进行战斗的场合，伤害步骤内这张卡的攻击力上升200。
function c25771826.initial_effect(c)
	-- 这张卡和光属性怪兽进行战斗的场合，伤害步骤内这张卡的攻击力上升200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c25771826.condtion)
	e1:SetValue(200)
	c:RegisterEffect(e1)
end
-- 判定当前是否处于伤害步骤或伤害计算时，并检查本卡是否正与表侧表示的光属性怪兽进行战斗（自身为攻击方或攻击对象时均可），以此作为攻击力上升效果的发动条件。
function c25771826.condtion(e)
	-- 获取当前游戏阶段，用于判断是否处于伤害步骤或伤害计算时。
	local ph=Duel.GetCurrentPhase()
	if not (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) then return false end
	-- 获取当前战斗的攻击怪兽，用于判断是否为本卡与光属性怪兽战斗。
	local a=Duel.GetAttacker()
	-- 获取当前战斗的被攻击怪兽（攻击对象），用于判断对方是否为表侧表示的光属性怪兽。
	local d=Duel.GetAttackTarget()
	return (a==e:GetHandler() and d and d:IsFaceup() and d:IsAttribute(ATTRIBUTE_LIGHT))
		or (d==e:GetHandler() and a:IsAttribute(ATTRIBUTE_LIGHT))
end
