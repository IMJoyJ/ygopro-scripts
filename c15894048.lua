--究極恐獣
-- 效果：
-- ①：自己战斗阶段有可以攻击的「究极恐兽」存在的场合，「究极恐兽」以外的怪兽不能攻击。
-- ②：这张卡可以向对方怪兽全部各作1次攻击。
function c15894048.initial_effect(c)
	-- ①：自己战斗阶段有可以攻击的「究极恐兽」存在的场合，「究极恐兽」以外的怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(c15894048.cacon)
	e1:SetTarget(c15894048.catg)
	c:RegisterEffect(e1)
	-- ②：这张卡可以向对方怪兽全部各作1次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_ATTACK_ALL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 该条件函数用于判断①效果的发动条件：当前必须是战斗阶段，且本卡的控制者为当前回合玩家，即满足“自己战斗阶段”的要求。
function c15894048.cacon(e)
	-- 检查当前是否为战斗阶段，并且本卡的控制者是否是当前回合玩家（确保是自己回合的战斗阶段）。
	return Duel.IsBattlePhase() and Duel.IsTurnPlayer(e:GetHandlerPlayer())
end
-- 这是EFFECT_CANNOT_ATTACK的Target函数，决定哪些怪兽不能攻击：若c不是「究极恐兽」，且己方场上存在至少1只可以攻击的「究极恐兽」，则c不能攻击。
function c15894048.catg(e,c)
	return not c:IsCode(15894048)
		-- 进一步确认己方场上存在至少1只满足cfilter条件的「究极恐兽」（即可以攻击的「究极恐兽」），作为禁止其他怪兽攻击的前提。
		and Duel.IsExistingMatchingCard(c15894048.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,c)
end
-- 过滤函数：判断一张卡是否为可以攻击的「究极恐兽」——卡名必须是「究极恐兽」，本身处于可攻击状态，并且拥有可攻击的目标或可以直接攻击。用于判断场上是否存在“可以攻击的「究极恐兽」”。
function c15894048.cfilter(c)
	if not (c:IsCode(15894048) and c:IsAttackable()) then return false end
	local ag,direct=c:GetAttackableTarget()
	return ag:GetCount()>0 or direct
end
