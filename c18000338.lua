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
-- 判定效果适用条件：当前处于伤害步骤或伤害计算时，这张卡与战斗相关，且战斗对象位于额外怪兽区域（格序号≥5），满足条件时攻击力·守备力提升效果生效。
function c18000338.condition(e)
	local c=e:GetHandler()
	-- 获取当前游戏阶段，用于判断是否处于伤害步骤或伤害计算时。
	local ph=Duel.GetCurrentPhase()
	local bc=c:GetBattleTarget()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
		and c:IsRelateToBattle() and bc and bc:GetSequence()>=5
end
