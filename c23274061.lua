--エレキタリス
-- 效果：
-- 这张卡在同1次的战斗阶段中可以作2次攻击。和这张卡进行战斗的效果怪兽的效果在伤害计算后无效化。
function c23274061.initial_effect(c)
	-- 这张卡在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 和这张卡进行战斗的效果怪兽的效果在伤害计算后无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23274061,0))  --"效果无效化"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLED)
	e2:SetCondition(c23274061.condition)
	e2:SetOperation(c23274061.operation)
	c:RegisterEffect(e2)
end
-- 判断攻击怪兽是否为效果怪兽且与本次战斗相关。
function c23274061.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取此次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 若攻击怪兽是自己，则获取攻击目标怪兽。
	if a==c then a=Duel.GetAttackTarget() end
	e:SetLabelObject(a)
	return a and a:IsType(TYPE_EFFECT) and a:IsRelateToBattle()
end
-- 对战斗怪兽施加效果无效和效果破坏效果。
function c23274061.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsFacedown() or not tc:IsRelateToBattle() then return end
	-- 使目标怪兽的效果无效。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+0x57a0000)
	tc:RegisterEffect(e1)
	-- 使目标怪兽的效果无效。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+0x57a0000)
	tc:RegisterEffect(e2)
end
