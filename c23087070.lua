--ローズ・ウィッチ
-- 效果：
-- 植物族怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
function c23087070.initial_effect(c)
	-- 植物族怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e1:SetValue(c23087070.condition)
	c:RegisterEffect(e1)
end
-- 当怪兽进行上级召唤时，若其为植物族，则可将其作为2个祭品进行解放
function c23087070.condition(e,c)
	return c:IsRace(RACE_PLANT)
end
