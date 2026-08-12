--アマゾネスの剣士
-- 效果：
-- ①：这张卡的战斗发生的对自己的战斗伤害由对方代受。
function c94004268.initial_effect(c)
	-- ①：这张卡的战斗发生的对自己的战斗伤害由对方代受。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
