--墓守の長槍兵
-- 效果：
-- 这张卡攻击守备表示的怪兽时，若这张卡的攻击力高于守备怪兽的守备力，则超过部分的数值对对方造成战斗伤害。
function c63695531.initial_effect(c)
	-- 这张卡攻击守备表示的怪兽时，若这张卡的攻击力高于守备怪兽的守备力，则超过部分的数值对对方造成战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
end
