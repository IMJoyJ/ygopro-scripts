--ポセイドン・オオカブト
-- 效果：
-- 这张卡向对方场上表侧攻击表示存在的怪兽攻击，那只怪兽没被战斗破坏的场合，可以向同只怪兽继续攻击。这个效果1回合可以使用最多2次。
function c75292259.initial_effect(c)
	-- 这张卡向对方场上表侧攻击表示存在的怪兽攻击，那只怪兽没被战斗破坏的场合，可以向同只怪兽继续攻击。这个效果1回合可以使用最多2次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(c75292259.atcon)
	e1:SetOperation(c75292259.atop)
	c:RegisterEffect(e1)
end
-- 判断是否满足连续攻击的条件：自身是攻击怪兽、存在战斗对象且未被战斗破坏、战斗对象原为表侧攻击表示、且自身本回合攻击次数未满3次（即最多使用2次效果）
function c75292259.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 确认自身是攻击怪兽，且存在战斗对象，且该战斗对象在伤害步骤结束时仍与战斗关联（未被战斗破坏送去墓地或除外）
	return c==Duel.GetAttacker() and bc and bc:IsRelateToBattle()
		and bc:GetBattlePosition()==POS_FACEUP_ATTACK and c:IsChainAttackable(3)
end
-- 执行连续攻击效果的操作函数
function c75292259.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 使自身可以向同一只战斗对象怪兽继续进行1次攻击
	Duel.ChainAttack(e:GetHandler():GetBattleTarget())
end
