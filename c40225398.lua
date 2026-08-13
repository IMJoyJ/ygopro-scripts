--ツイン・ブレイカー
-- 效果：
-- 这张卡向守备表示怪兽攻击的场合，只有1次可以继续攻击。这张卡攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c40225398.initial_effect(c)
	-- ②：这张卡向守备表示怪兽进行过攻击的场合，只再1次可以继续攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetOperation(c40225398.caop)
	c:RegisterEffect(e1)
	-- ①：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
end
-- 伤害步骤结束时触发处理：若本卡攻击过守备表示怪兽、本卡仍与战斗关联且可连续攻击，则让本卡获得再攻击一次的机会。
function c40225398.caop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 判定条件：当前攻击者正是本卡，且存在战斗对象，该对象在战斗发生前为守备表示，本卡未因本次战斗离场，并且本卡满足连续攻击的条件。
	if Duel.GetAttacker()==c and bc and bit.band(bc:GetBattlePosition(),POS_DEFENSE)~=0 and c:IsRelateToBattle() and c:IsChainAttackable() then
		-- 执行连续攻击，使本卡可以再进行1次攻击。
		Duel.ChainAttack()
	end
end
