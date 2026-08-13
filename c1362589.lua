--フォトン・クラッシャー
-- 效果：
-- ①：这张卡攻击的场合，伤害步骤结束时变成守备表示。
function c1362589.initial_effect(c)
	-- ①：这张卡攻击的场合，伤害步骤结束时变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(c1362589.poscon)
	e1:SetOperation(c1362589.posop)
	c:RegisterEffect(e1)
end
-- 效果的条件判断函数：用于判定伤害步骤结束时是否满足触发条件，即本卡是否为进行攻击的怪兽且与本次战斗相关。
function c1362589.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回效果持有者是否为本次攻击的攻击怪兽，且该怪兽仍与本次战斗相关（未离场或未脱离战斗），确保效果只在自身攻击并存在于场上时发动。
	return e:GetHandler()==Duel.GetAttacker() and e:GetHandler():IsRelateToBattle()
end
-- 效果的处理函数：在伤害步骤结束时，若效果持有者仍处于表侧攻击表示，则将其变成表侧守备表示。
function c1362589.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将这张卡从表侧攻击表示改变为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
