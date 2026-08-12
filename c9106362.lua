--EMドラネコ
-- 效果：
-- ←2 【灵摆】 2→
-- ①：1回合1次，对方怪兽的直接攻击宣言时才能发动。那次战斗发生的对自己的战斗伤害变成0。
-- 【怪兽效果】
-- ①：1回合1次，自己怪兽和对方怪兽进行战斗的攻击宣言时才能发动。那次战斗发生的对自己的战斗伤害变成0。
function c9106362.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性（注册灵摆召唤和灵摆卡的发动效果）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，对方怪兽的直接攻击宣言时才能发动。那次战斗发生的对自己的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9106362,0))  --"战斗伤害变成0"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1)
	e1:SetCondition(c9106362.dmcon1)
	e1:SetOperation(c9106362.dmop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c9106362.dmcon2)
	e2:SetOperation(c9106362.dmop)
	c:RegisterEffect(e2)
end
-- 定义灵摆效果的发动条件函数（对方怪兽直接攻击宣言时）
function c9106362.dmcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击怪兽是否由对方控制，且攻击对象为空（即直接攻击）
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 定义怪兽效果的发动条件函数（自己怪兽和对方怪兽进行战斗的攻击宣言时）
function c9106362.dmcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽
	local a=Duel.GetAttacker()
	-- 获取当前被攻击的怪兽
	local d=Duel.GetAttackTarget()
	return d and a:GetControler()~=d:GetControler()
end
-- 定义效果处理函数（使那次战斗发生的对自己的战斗伤害变成0）
function c9106362.dmop(e,tp,eg,ep,ev,re,r,rp)
	-- 那次战斗发生的对自己的战斗伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 在全局环境中为玩家注册该免受战斗伤害的效果
	Duel.RegisterEffect(e1,tp)
end
