--A・O・J ルドラ
-- 效果：
-- 这张卡和光属性怪兽进行战斗的场合，伤害步骤内这张卡的攻击力上升700。
function c52265835.initial_effect(c)
	-- 这张卡和光属性怪兽进行战斗的场合，伤害步骤内这张卡的攻击力上升700。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c52265835.condtion)
	e1:SetValue(700)
	c:RegisterEffect(e1)
end
-- 判断当前是否为伤害步骤且确认战斗涉及光属性怪兽
function c52265835.condtion(e)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	if not (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) then return false end
	-- 获取本次战斗的攻击者
	local a=Duel.GetAttacker()
	-- 获取本次战斗的攻击对象
	local d=Duel.GetAttackTarget()
	return (a==e:GetHandler() and d and d:IsFaceup() and d:IsAttribute(ATTRIBUTE_LIGHT))
		or (d==e:GetHandler() and a:IsAttribute(ATTRIBUTE_LIGHT))
end
