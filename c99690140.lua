--墓守の従者
-- 效果：
-- 这张卡给与对方造成的战斗伤害，算作这张卡的效果造成的伤害使用。
function c99690140.initial_effect(c)
	-- 这张卡给与对方造成的战斗伤害，算作这张卡的效果造成的伤害使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_BATTLE_DAMAGE_TO_EFFECT)
	c:RegisterEffect(e1)
end
