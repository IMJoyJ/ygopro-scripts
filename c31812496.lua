--アステカの石像
-- 效果：
-- ①：这张卡被攻击的场合，那次战斗发生的对对方的战斗伤害变成2倍。
function c31812496.initial_effect(c)
	-- ①：这张卡被攻击的场合，那次战斗发生的对对方的战斗伤害变成2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_INVOLVING_BATTLE_DAMAGE)
	e1:SetCondition(c31812496.dcon)
	-- 设置战斗伤害变为2倍
	e1:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e1)
end
-- 判断是否为攻击状态的怪兽被攻击
function c31812496.dcon(e)
	local c=e:GetHandler()
	-- 判断攻击目标是否为该卡
	return Duel.GetAttackTarget()==c
end
