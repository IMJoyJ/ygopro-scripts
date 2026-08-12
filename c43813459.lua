--反射光子流
-- 效果：
-- 自己场上的龙族·光属性怪兽被选择作为攻击对象时才能发动。那只攻击对象怪兽的攻击力直到伤害步骤结束时上升攻击怪兽的攻击力数值。
function c43813459.initial_effect(c)
	-- 自己场上的龙族·光属性怪兽被选择作为攻击对象时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(c43813459.condition)
	e1:SetTarget(c43813459.target)
	e1:SetOperation(c43813459.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组，判断攻击怪兽是否在场且攻击对象怪兽是否为光属性龙族。
function c43813459.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗中攻击的卡
	local a=Duel.GetAttacker()
	-- 获取此次战斗中被选为攻击对象的卡
	local d=Duel.GetAttackTarget()
	return a:IsOnField() and d and d:IsFaceup() and d:IsControler(tp) and d:IsAttribute(ATTRIBUTE_LIGHT) and d:IsRace(RACE_DRAGON)
end
-- 设置效果目标，将攻击怪兽和攻击对象怪兽与效果建立联系。
function c43813459.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 为攻击怪兽与效果建立联系
	Duel.GetAttacker():CreateEffectRelation(e)
	-- 为攻击对象怪兽与效果建立联系
	Duel.GetAttackTarget():CreateEffectRelation(e)
end
-- 发动效果，使攻击对象怪兽的攻击力在伤害步骤结束前上升攻击怪兽的攻击力数值。
function c43813459.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗中攻击的卡
	local a=Duel.GetAttacker()
	-- 获取此次战斗中被选为攻击对象的卡
	local d=Duel.GetAttackTarget()
	if a:IsFacedown() or not a:IsRelateToEffect(e) or d:IsFacedown() or not d:IsRelateToEffect(e) then return end
	-- 那只攻击对象怪兽的攻击力直到伤害步骤结束时上升攻击怪兽的攻击力数值。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(a:GetAttack())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
	d:RegisterEffect(e1)
end
