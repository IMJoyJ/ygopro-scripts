--太陽の戦士
-- 效果：
-- 和暗属性的怪兽战斗的场合，伤害计算阶段这张卡的攻击力上升500。
function c57482479.initial_effect(c)
	-- 和暗属性的怪兽战斗的场合，伤害计算阶段这张卡的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(c57482479.condtion)
	e1:SetValue(500)
	c:RegisterEffect(e1)
end
-- 判断是否在伤害步骤或伤害计算时与表侧表示的暗属性怪兽进行战斗
function c57482479.condtion(e)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	if not (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) or not e:GetHandler():IsRelateToBattle() then return false end
	local bc=e:GetHandler():GetBattleTarget()
	return bc and bc:IsFaceup() and bc:IsAttribute(ATTRIBUTE_DARK)
end
