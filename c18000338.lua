--Re：EX
-- 效果：
-- ①：这张卡和额外怪兽区域的怪兽进行战斗的场合，只在伤害步骤内这张卡的攻击力·守备力上升800。
function c18000338.initial_effect(c)
	-- ①：这张卡和额外怪兽区域的怪兽进行战斗的场合，只在伤害步骤内这张卡的攻击力·守备力上升800。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c18000338.condition)
	e1:SetValue(800)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
end
-- 判断当前是否处于伤害步骤或伤害计算阶段，并确保此卡与敌方怪兽战斗且敌方怪兽在额外怪兽区域
function c18000338.condition(e)
	local c=e:GetHandler()
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	local bc=c:GetBattleTarget()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
		and c:IsRelateToBattle() and bc and bc:GetSequence()>=5
end
