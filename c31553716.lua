--スピア・ドラゴン
-- 效果：
-- ①：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ②：这张卡攻击的场合，伤害步骤结束时变成守备表示。
function c31553716.initial_effect(c)
	-- ②：这张卡攻击的场合，伤害步骤结束时变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(c31553716.poscon)
	e1:SetOperation(c31553716.posop)
	c:RegisterEffect(e1)
	-- ①：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
end
-- ②效果的发动条件判断：由效果持有者自身发动，且仅当效果持有者就是本次战斗的攻击怪兽，并且仍与本次战斗相关（没有因离场等导致战斗关系失效）时才成立。
function c31553716.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定效果持有者是否为当前攻击怪兽（Duel.GetAttacker）并且仍与本次战斗关联（IsRelateToBattle），两者均满足时条件通过。
	return e:GetHandler()==Duel.GetAttacker() and e:GetHandler():IsRelateToBattle()
end
-- ②效果处理：在伤害步骤结束时，若效果持有者（本卡）仍为攻击表示，则将其变更为守备表示。
function c31553716.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 调用Duel.ChangePosition，将本卡的表示形式改为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
