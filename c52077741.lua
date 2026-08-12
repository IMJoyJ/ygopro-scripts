--翻弄するエルフの剣士
-- 效果：
-- ①：这张卡不会被和攻击力1900以上的怪兽的战斗破坏。
function c52077741.initial_effect(c)
	-- ①：这张卡不会被和攻击力1900以上的怪兽的战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(c52077741.indes)
	c:RegisterEffect(e1)
end
-- 判断该卡是否因战斗而不会被破坏，若为守备表示且攻击怪兽是自身，则判断其守备力是否不低于1900，否则判断其攻击力是否不低于1900。
function c52077741.indes(e,c)
	-- 当此卡处于守备表示且作为攻击怪兽时的条件判断
	if c:IsDefensePos() and Duel.GetAttacker()==c then
		return c:IsDefenseAbove(1900)
	else
		return c:IsAttackAbove(1900)
	end
end
