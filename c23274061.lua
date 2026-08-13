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
-- 判断本次战斗对象是否为效果怪兽且仍与本次战斗相关，若是则将该怪兽保存为效果处理对象；本卡为攻击方时取攻击目标，本卡为被攻击方时取攻击怪兽。
function c23274061.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 如果攻击怪兽是本卡（即本卡主动攻击），则将战斗对象改为攻击目标（即与本卡战斗的对方怪兽）。
	if a==c then a=Duel.GetAttackTarget() end
	e:SetLabelObject(a)
	return a and a:IsType(TYPE_EFFECT) and a:IsRelateToBattle()
end
-- 取出记录的战斗对象；若该对象已里侧表示或已不与本次战斗关联则直接结束；否则给该对象注册怪兽效果无效化和效果无效状态两个效果，并设置其离场等情况下重置。
function c23274061.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsFacedown() or not tc:IsRelateToBattle() then return end
	-- 和这张卡进行战斗的效果怪兽的效果在伤害计算后无效化。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+0x57a0000)
	tc:RegisterEffect(e1)
	-- 和这张卡进行战斗的效果怪兽的效果在伤害计算后无效化。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+0x57a0000)
	tc:RegisterEffect(e2)
end
