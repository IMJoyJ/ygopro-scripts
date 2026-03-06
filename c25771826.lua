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
-- 判断是否满足效果发动条件，包括当前阶段是否为伤害步骤或伤害计算时，以及攻击怪兽或防守怪兽是否为光属性。
function c25771826.condtion(e)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	if not (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) then return false end
	-- 获取此次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取此次战斗的防守怪兽
	local d=Duel.GetAttackTarget()
	return (a==e:GetHandler() and d and d:IsFaceup() and d:IsAttribute(ATTRIBUTE_LIGHT))
		or (d==e:GetHandler() and a:IsAttribute(ATTRIBUTE_LIGHT))
end
