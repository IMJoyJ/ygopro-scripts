--A・O・J ブラインド・サッカー
-- 效果：
-- 和这张卡进行战斗的光属性怪兽的效果在伤害计算后无效化。
function c76650663.initial_effect(c)
	-- 和这张卡进行战斗的光属性怪兽的效果在伤害计算后无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76650663,0))  --"效果无效化"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(c76650663.condition)
	e1:SetOperation(c76650663.operation)
	c:RegisterEffect(e1)
end
-- 判断触发条件：获取与自身战斗的怪兽，并确认其为光属性且仍处于战斗关系中。
function c76650663.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 如果自身是攻击怪兽，则将对方怪兽（攻击目标）作为目标怪兽。
	if a==c then a=Duel.GetAttackTarget() end
	e:SetLabelObject(a)
	return a and a:IsAttribute(ATTRIBUTE_LIGHT) and a:IsRelateToBattle()
end
-- 执行效果：如果目标怪兽未变成里侧表示且仍处于战斗关系中，则将其效果无效化。
function c76650663.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsFacedown() or not tc:IsRelateToBattle() then return end
	-- 效果在伤害计算后无效化
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+0x57a0000)
	tc:RegisterEffect(e1)
	-- 效果在伤害计算后无效化
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+0x57a0000)
	tc:RegisterEffect(e2)
end
