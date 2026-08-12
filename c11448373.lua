--グレイヴ・キーパー
-- 效果：
-- 当这张卡在场上以表侧表示存在时，被战斗破坏的怪兽不再被送去墓地，直接回到持有者卡组。
function c11448373.initial_effect(c)
	-- 当这张卡在场上以表侧表示存在时，被战斗破坏的怪兽不再被送去墓地，直接回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetValue(LOCATION_DECKSHF)
	c:RegisterEffect(e1)
end
