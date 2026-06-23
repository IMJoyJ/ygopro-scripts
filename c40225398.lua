--ツイン・ブレイカー
-- 效果：
-- 这张卡向守备表示怪兽攻击的场合，只有1次可以继续攻击。这张卡攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c40225398.initial_effect(c)
	-- 这张卡向守备表示怪兽攻击的场合，只有1次可以继续攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetOperation(c40225398.caop)
	c:RegisterEffect(e1)
	-- 这张卡攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
end
-- 在伤害步骤结束时，检查是否满足连续攻击条件，若满足则执行连续攻击。
function c40225398.caop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 判断当前攻击怪兽为本卡、战斗对象存在、战斗对象为守备表示、本卡与战斗相关、且可进行连续攻击。
	if Duel.GetAttacker()==c and bc and bit.band(bc:GetBattlePosition(),POS_DEFENSE)~=0 and c:IsRelateToBattle() and c:IsChainAttackable() then
		-- 使本次攻击的怪兽可以再进行1次攻击。
		Duel.ChainAttack()
	end
end
