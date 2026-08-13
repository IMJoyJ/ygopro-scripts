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
-- 定义战斗破坏免疫的判定回调：若被判定怪兽处于守备表示且为攻击怪兽，则检查其守备力是否≥1900；否则检查其攻击力是否≥1900，满足条件则不会被那次战斗破坏。
function c52077741.indes(e,c)
	-- 判断当前被判定对象是否处于守备表示，并且同时是此次战斗的攻击怪兽（若满足则进入守备力判定分支）。
	if c:IsDefensePos() and Duel.GetAttacker()==c then
		return c:IsDefenseAbove(1900)
	else
		return c:IsAttackAbove(1900)
	end
end
