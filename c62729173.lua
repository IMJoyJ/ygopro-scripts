--インヴェルズ万能態
-- 效果：
-- 名字带有「侵入魔鬼」的怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
function c62729173.initial_effect(c)
	-- 名字带有「侵入魔鬼」的怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e1:SetValue(c62729173.condition)
	c:RegisterEffect(e1)
end
-- 判断进行上级召唤的怪兽是否是名字带有「侵入魔鬼」的怪兽
function c62729173.condition(e,c)
	return c:IsSetCard(0x100a)
end
