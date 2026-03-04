--フォトン・クラッシャー
-- 效果：
-- ①：这张卡攻击的场合，伤害步骤结束时变成守备表示。
function c1362589.initial_effect(c)
	-- 效果原文内容：①：这张卡攻击的场合，伤害步骤结束时变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(c1362589.poscon)
	e1:SetOperation(c1362589.posop)
	c:RegisterEffect(e1)
end
-- 判断条件函数开始
function c1362589.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前卡是否为攻击方且与本次战斗相关
	return e:GetHandler()==Duel.GetAttacker() and e:GetHandler():IsRelateToBattle()
end
-- 效果处理函数开始
function c1362589.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将目标怪兽变为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
