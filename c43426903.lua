--レプティレス・ゴルゴーン
-- 效果：
-- 这张卡进行攻击的伤害计算后，和这张卡进行战斗的怪兽攻击力变成0，变成不能把表示形式改变。
function c43426903.initial_effect(c)
	-- 这张卡进行攻击的伤害计算后，和这张卡进行战斗的怪兽攻击力变成0，变成不能把表示形式改变。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43426903,0))  --"攻击变成0，不能改变表示形式"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(c43426903.condition)
	e1:SetOperation(c43426903.operation)
	c:RegisterEffect(e1)
end
-- 效果作用
function c43426903.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 满足条件：此卡为攻击怪兽且存在攻击对象
	return e:GetHandler()==Duel.GetAttacker() and Duel.GetAttackTarget()
end
-- 效果作用
function c43426903.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击对象
	local d=Duel.GetAttackTarget()
	if not d:IsRelateToBattle() then return end
	-- 攻击变成0
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(0)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	d:RegisterEffect(e1)
	-- 不能把表示形式改变
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	d:RegisterEffect(e2)
end
