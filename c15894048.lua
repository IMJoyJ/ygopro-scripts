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
-- 判断是否处于战斗阶段且为当前玩家的回合
function c15894048.cacon(e)
	-- 判断是否处于战斗阶段且为当前玩家的回合
	return Duel.IsBattlePhase() and Duel.IsTurnPlayer(e:GetHandlerPlayer())
end
-- 设定效果目标为非究极恐兽且存在可攻击的究极恐兽
function c15894048.catg(e,c)
	return not c:IsCode(15894048)
		-- 检查场上是否存在可攻击的究极恐兽
		and Duel.IsExistingMatchingCard(c15894048.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,c)
end
-- 检查该究极恐兽是否可以攻击并具有攻击目标
function c15894048.cfilter(c)
	if not (c:IsCode(15894048) and c:IsAttackable()) then return false end
	local ag,direct=c:GetAttackableTarget()
	return ag:GetCount()>0 or direct
end
