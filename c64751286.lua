--月の女戦士
-- 效果：
-- 与光属性怪兽战斗的场合，在伤害步骤内这张卡攻击力上升1000。
function c64751286.initial_effect(c)
	-- 与光属性怪兽战斗的场合，在伤害步骤内这张卡攻击力上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(c64751286.condtion)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
end
-- 判断是否在伤害步骤（或伤害计算时）与表侧表示的光属性怪兽进行战斗
function c64751286.condtion(e)
	local c=e:GetHandler()
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	local bc=c:GetBattleTarget()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
		and c:IsRelateToBattle() and bc and bc:IsFaceup() and bc:IsAttribute(ATTRIBUTE_LIGHT)
end
