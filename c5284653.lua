--ヴェルズ・オ・ウィスプ
-- 效果：
-- 和这张卡进行战斗的效果怪兽的效果在伤害计算后无效化。
function c5284653.initial_effect(c)
	-- 和这张卡进行战斗的效果怪兽的效果在伤害计算后无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5284653,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(c5284653.condition)
	e1:SetOperation(c5284653.operation)
	c:RegisterEffect(e1)
end
-- 判断攻击怪兽是否为效果怪兽且与本次战斗相关
function c5284653.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取此次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 若攻击怪兽是自己，则获取攻击目标怪兽
	if a==c then a=Duel.GetAttackTarget() end
	e:SetLabelObject(a)
	return a and a:IsType(TYPE_EFFECT) and a:IsRelateToBattle()
end
-- 将攻击怪兽的效果无效化
function c5284653.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsFacedown() or not tc:IsRelateToBattle() then return end
	-- 针对怪兽的效果无效
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+0x57a0000)
	tc:RegisterEffect(e1)
	-- 针对效果的效果无效
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+0x57a0000)
	tc:RegisterEffect(e2)
end
