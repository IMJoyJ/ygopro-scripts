--ロードランナー
-- 效果：
-- ①：这张卡不会被和攻击力1900以上的怪兽的战斗破坏。
function c36472900.initial_effect(c)
	-- ①：这张卡不会被和攻击力1900以上的怪兽的战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(c36472900.indes)
	c:RegisterEffect(e1)
end
-- 定义战斗破坏免疫的判定函数：根据与这张卡战斗的对方怪兽的状态，判断其攻击力或守备力是否达到1900以上，达到则返回真值，使这张卡不会被那次战斗破坏。
function c36472900.indes(e,c)
	-- 判断战斗对象c是否为守备表示且为当前攻击怪兽（即以守备力进行攻击的特殊战斗状态），若是则后续使用守备力进行1900的数值判定。
	if c:IsDefensePos() and Duel.GetAttacker()==c then
		return c:IsDefenseAbove(1900)
	else
		return c:IsAttackAbove(1900)
	end
end
