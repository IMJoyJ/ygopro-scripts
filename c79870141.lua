--猛進する剣角獣
-- 效果：
-- 攻击守备表示的怪兽时，这张卡的攻击力超过守备表示怪兽的守备力，对方受到这个超过的数值的战斗伤害。
function c79870141.initial_effect(c)
	-- 攻击守备表示的怪兽时，这张卡的攻击力超过守备表示怪兽的守备力，对方受到这个超过的数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
end
