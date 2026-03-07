--モンク・ファイター
-- 效果：
-- 这张卡进行战斗使控制者受到的战斗伤害为0。
function c3810071.initial_effect(c)
	-- 这张卡进行战斗使控制者受到的战斗伤害为0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
