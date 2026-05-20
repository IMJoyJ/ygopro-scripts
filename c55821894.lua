--アマゾネスの格闘戦士
-- 效果：
-- 这张卡进行战斗时，这张卡的控制者所受的战斗伤害为零。
function c55821894.initial_effect(c)
	-- 这张卡进行战斗时，这张卡的控制者所受的战斗伤害为零。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
