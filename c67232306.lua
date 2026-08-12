--聖なる鎧 －ミラーメール－
-- 效果：
-- 自己场上表侧表示存在的怪兽被选择作为攻击对象时才能发动。攻击对象怪兽的攻击力变成和攻击怪兽的攻击力相同。
function c67232306.initial_effect(c)
	-- 自己场上表侧表示存在的怪兽被选择作为攻击对象时才能发动。攻击对象怪兽的攻击力变成和攻击怪兽的攻击力相同。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetTarget(c67232306.target)
	e1:SetOperation(c67232306.operation)
	c:RegisterEffect(e1)
end
-- 检查作为攻击对象的怪兽是否为自己场上表侧表示的怪兽，且攻击怪兽在场，并为这两张卡建立与该效果的联系。
function c67232306.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local at=eg:GetFirst()
	-- 获取此次战斗中发起攻击的怪兽。
	local a=Duel.GetAttacker()
	if chk==0 then return at:IsControler(tp) and at:IsOnField() and at:IsFaceup() and a:IsOnField() end
	at:CreateEffectRelation(e)
	a:CreateEffectRelation(e)
end
-- 在效果处理时，确认攻击怪兽与攻击对象怪兽依然与此效果有关联且均为表侧表示，然后将攻击对象怪兽的攻击力变成和攻击怪兽的当前攻击力相同。
function c67232306.operation(e,tp,eg,ep,ev,re,r,rp)
	local at=eg:GetFirst()
	-- 获取此次战斗中发起攻击的怪兽。
	local a=Duel.GetAttacker()
	if not a:IsRelateToEffect(e) or not at:IsRelateToEffect(e) or a:IsFacedown() or at:IsFacedown() then return end
	-- 攻击对象怪兽的攻击力变成和攻击怪兽的攻击力相同。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(a:GetAttack())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	at:RegisterEffect(e1)
end
