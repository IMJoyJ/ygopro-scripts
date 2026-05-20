--暗黒ドリケラトプス
-- 效果：
-- 这张卡攻击守备表示的怪兽时，攻击力超出部分对对方造成战斗伤害。
function c65287621.initial_effect(c)
	-- 这张卡攻击守备表示的怪兽时，攻击力超出部分对对方造成战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
end
