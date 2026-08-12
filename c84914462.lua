--アックス・ドラゴニュート
-- 效果：
-- ①：这张卡攻击的场合，伤害步骤结束时变成守备表示。
function c84914462.initial_effect(c)
	-- ①：这张卡攻击的场合，伤害步骤结束时变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(c84914462.poscon)
	e1:SetOperation(c84914462.posop)
	c:RegisterEffect(e1)
end
-- 设置效果触发条件：这张卡进行攻击，且在伤害步骤结束时仍与战斗关联
function c84914462.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断这张卡是否是本次战斗的攻击怪兽，且在伤害步骤结束时仍与战斗关联
	return e:GetHandler()==Duel.GetAttacker() and e:GetHandler():IsRelateToBattle()
end
-- 设置效果执行操作：若这张卡仍为攻击表示，则将其变更为表侧守备表示
function c84914462.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将这张卡变更为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
