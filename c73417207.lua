--極星霊スヴァルトアールヴ
-- 效果：
-- 把这张卡作为同调素材的场合，其他的同调素材怪兽必须是手卡2只名字带有「极星」的怪兽。
function c73417207.initial_effect(c)
	-- 把这张卡作为同调素材的场合，其他的同调素材怪兽必须是手卡2只名字带有「极星」的怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TUNER_MATERIAL_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetTarget(c73417207.synlimit)
	e1:SetTargetRange(2,2)
	e1:SetValue(LOCATION_HAND)
	c:RegisterEffect(e1)
end
-- 判定其他的同调素材怪兽是否为名字带有「极星」的怪兽
function c73417207.synlimit(e,c)
	return c:IsSetCard(0x42)
end
