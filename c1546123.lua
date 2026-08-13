--サイバー・エンド・ドラゴン
-- 效果：
-- 「电子龙」＋「电子龙」＋「电子龙」
-- 这张卡的融合召唤不用上记的卡不能进行。
-- ①：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c1546123.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：需要以3只『电子龙』（卡号70095154）为融合素材，且不能使用其他融合素材代替，即这张卡的融合召唤不用上记的卡不能进行。
	aux.AddFusionProcCodeRep(c,70095154,3,false,false)
	-- ①：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
end
c1546123.material_setcode=0x1093
