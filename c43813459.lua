--反射光子流
-- 效果：
-- 自己场上的龙族·光属性怪兽被选择作为攻击对象时才能发动。那只攻击对象怪兽的攻击力直到伤害步骤结束时上升攻击怪兽的攻击力数值。
function c43813459.initial_effect(c)
	-- 自己场上的龙族·光属性怪兽被选择作为攻击对象时才能发动。那只攻击对象怪兽的攻击力直到伤害步骤结束时上升攻击怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(c43813459.condition)
	e1:SetTarget(c43813459.target)
	e1:SetOperation(c43813459.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定：当攻击怪兽在场上，且被选择作为攻击对象的怪兽存在、表侧表示、为自己场上且为光属性龙族怪兽时才满足发动条件。
function c43813459.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗阶段发起攻击的怪兽。
	local a=Duel.GetAttacker()
	-- 获取当前被选择为攻击对象的怪兽。
	local d=Duel.GetAttackTarget()
	return a:IsOnField() and d and d:IsFaceup() and d:IsControler(tp) and d:IsAttribute(ATTRIBUTE_LIGHT) and d:IsRace(RACE_DRAGON)
end
-- 发动时确定效果必定会处理，并将攻击怪兽与攻击对象怪兽分别和本效果建立关联，以便效果处理时确认它们是否仍然有效。
function c43813459.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将攻击怪兽与本效果建立关联，用于后续处理时判断该怪兽是否仍与效果相关。
	Duel.GetAttacker():CreateEffectRelation(e)
	-- 将攻击对象怪兽与本效果建立关联，用于后续处理时判断该怪兽是否仍与效果相关。
	Duel.GetAttackTarget():CreateEffectRelation(e)
end
-- 效果处理：先确认攻击怪兽和攻击对象怪兽都未变成里侧且仍与本效果关联，若满足则给攻击对象怪兽附加一个攻击力上升效果，上升值等于攻击怪兽当前的攻击力，并持续到伤害步骤结束。
function c43813459.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗阶段发起攻击的怪兽。
	local a=Duel.GetAttacker()
	-- 获取当前被选择为攻击对象的怪兽。
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
