--レッサー・デーモン
-- 效果：
-- 只要这张卡在场上表侧表示存在，这张卡战斗破坏的怪兽不送去墓地从游戏中除外。
function c16475472.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，这张卡战斗破坏的怪兽不送去墓地从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)
end
