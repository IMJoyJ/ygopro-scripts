--氷結界の修験者
-- 效果：
-- ①：这张卡不会被和攻击力1900以上的怪兽的战斗破坏。
function c20700531.initial_effect(c)
	-- ①：这张卡不会被和攻击力1900以上的怪兽的战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(c20700531.indes)
	c:RegisterEffect(e1)
end
-- 判断当前卡是否满足不被战斗破坏的条件，即攻击怪兽攻击力不低于1900或守备力不低于1900
function c20700531.indes(e,c)
	-- 判断当前卡是否处于守备表示且正作为攻击怪兽参与战斗
	if c:IsDefensePos() and Duel.GetAttacker()==c then
		return c:IsDefenseAbove(1900)
	else
		return c:IsAttackAbove(1900)
	end
end
