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
-- 效果条件函数，判断是否为攻击怪兽且参与了战斗
function c31553716.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前卡为攻击怪兽且与本次战斗相关
	return e:GetHandler()==Duel.GetAttacker() and e:GetHandler():IsRelateToBattle()
end
-- 效果执行函数，若攻击表示则变为守备表示
function c31553716.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将目标怪兽变为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
