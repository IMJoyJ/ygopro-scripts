--隼の騎士
-- 效果：
-- ①：这张卡在同1次的战斗阶段中可以作2次攻击。
function c21015833.initial_effect(c)
	-- ①：这张卡在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
