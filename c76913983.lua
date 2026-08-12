--BF－アームズ・ウィング
-- 效果：
-- 「黑羽」调整＋调整以外的怪兽1只以上
-- ①：这张卡向守备表示怪兽攻击的伤害步骤内，这张卡的攻击力上升500。
-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
function c76913983.initial_effect(c)
	-- 设置同调召唤手续：需要「黑羽」调整怪兽，以及1只以上的调整以外的怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x33),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡向守备表示怪兽攻击的伤害步骤内，这张卡的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(c76913983.atkcon)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
end
-- 判断攻击力上升效果是否满足条件的函数：需在伤害步骤内，且自身向守备表示怪兽进行攻击
function c76913983.atkcon(e)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	if ph~=PHASE_DAMAGE and ph~=PHASE_DAMAGE_CAL then return false end
	-- 获取进行攻击的怪兽
	local a=Duel.GetAttacker()
	-- 获取被攻击的怪兽
	local d=Duel.GetAttackTarget()
	return e:GetHandler()==a and d and d:IsDefensePos()
end
