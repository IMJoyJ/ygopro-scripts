--リバース・オブ・ザ・ワールド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把手卡的仪式怪兽解放，从手卡·卡组把「破灭之女神 露茵」或者「终焉之王 迪米斯」仪式召唤。
function c95612049.initial_effect(c)
	-- 注册一个仪式召唤效果，允许从手牌或卡组仪式召唤「破灭之女神 露茵」或「终焉之王 迪米斯」，并使用满足条件的仪式怪兽作为解放素材
	local e1=aux.AddRitualProcGreater2Code2(c,46427957,72426662,LOCATION_HAND+LOCATION_DECK,nil,c95612049.mfilter,true)
	e1:SetCountLimit(1,95612049+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
-- 定义仪式素材的过滤条件，限定为不在场上（即手牌中）的仪式怪兽
function c95612049.mfilter(c)
	return not c:IsOnField() and c:IsType(TYPE_RITUAL)
end
