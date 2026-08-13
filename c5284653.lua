--ヴェルズ・オ・ウィスプ
-- 效果：
-- 和这张卡进行战斗的效果怪兽的效果在伤害计算后无效化。
function c5284653.initial_effect(c)
	-- 对应卡片效果原文：和这张卡进行战斗的效果怪兽的效果在伤害计算后无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5284653,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(c5284653.condition)
	e1:SetOperation(c5284653.operation)
	c:RegisterEffect(e1)
end
-- 判定该诱发效果的发动条件：本卡与效果怪兽进行战斗，且该怪兽仍与这次战斗关联；将那只怪兽暂存为效果标签对象。
function c5284653.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次战斗的攻击怪兽，作为候选的“进行战斗的效果怪兽”。
	local a=Duel.GetAttacker()
	-- 如果攻击方是本卡（本卡主动攻击），则把对象改为攻击目标（对方怪兽），从而定位到与本卡战斗的怪兽。
	if a==c then a=Duel.GetAttackTarget() end
	e:SetLabelObject(a)
	return a and a:IsType(TYPE_EFFECT) and a:IsRelateToBattle()
end
-- 效果处理：从标签对象取出战斗怪兽；若它已里侧表示或已离场则取消，否则给它附加 EFFECT_DISABLE（怪兽效果无效）和 EFFECT_DISABLE_EFFECT（已发动效果无效），并设置在离场等事件时重置，完成伤害计算后的无效化。
function c5284653.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsFacedown() or not tc:IsRelateToBattle() then return end
	-- 对应效果原文：“和这张卡进行战斗的效果怪兽的效果在伤害计算后无效化。”——设置 EFFECT_DISABLE，使该怪兽的效果无效化。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+0x57a0000)
	tc:RegisterEffect(e1)
	-- 对应效果原文：“和这张卡进行战斗的效果怪兽的效果在伤害计算后无效化。”——设置 EFFECT_DISABLE_EFFECT，使该怪兽已发动的效果也无效化。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+0x57a0000)
	tc:RegisterEffect(e2)
end
