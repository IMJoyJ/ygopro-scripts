--精霊術師 ドリアード
-- 效果：
-- 「树精的祈祷」降临。这张卡的属性也同时当作「风」「水」「炎」「地」使用。
function c99414168.initial_effect(c)
	-- 记录该卡记载了「树精的祈祷」的卡名
	aux.AddCodeList(c,23965037)
	c:EnableReviveLimit()
	-- 这张卡的属性也同时当作「风」「水」「炎」「地」使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(0xf)
	c:RegisterEffect(e1)
end
