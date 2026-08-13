--アステカの石像
-- 效果：
-- ①：这张卡被攻击的场合，那次战斗发生的对对方的战斗伤害变成2倍。
function c31812496.initial_effect(c)
	-- ①：这张卡被攻击的场合，那次战斗发生的对对方的战斗伤害变成2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_INVOLVING_BATTLE_DAMAGE)
	e1:SetCondition(c31812496.dcon)
	-- 设置伤害变更效果的值：使用辅助函数生成一个值，使得这张卡参与的战斗中，对手受到的战斗伤害变为2倍。
	e1:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e1)
end
-- 定义效果适用的条件：当这张卡成为攻击对象（即被攻击）时，该伤害变更效果生效。
function c31812496.dcon(e)
	local c=e:GetHandler()
	-- 判断当前攻击对象是否就是这张卡，若是则条件成立，返回 true。
	return Duel.GetAttackTarget()==c
end
