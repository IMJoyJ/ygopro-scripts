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
-- 效果值函数：根据战斗对象（攻击怪兽）的表示形式，以其攻击力或（守备表示攻击时的）守备力是否≥1900，决定此卡是否适用不会被战斗破坏的耐性。
function c20700531.indes(e,c)
	-- 判断战斗对象是否为攻击者且处于守备表示（即以守备表示进行攻击），以选用其守备力还是攻击力进行判定。
	if c:IsDefensePos() and Duel.GetAttacker()==c then
		return c:IsDefenseAbove(1900)
	else
		return c:IsAttackAbove(1900)
	end
end
