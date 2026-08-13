--F・G・D
-- 效果：
-- 龙族怪兽×5
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：这张卡不会被和暗·地·水·炎·风属性怪兽的战斗破坏。
function c99267150.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：使用5只龙族怪兽作为融合素材，且允许里侧素材参与融合。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),5,true)
	-- ①：这张卡不会被和暗·地·水·炎·风属性怪兽的战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(c99267150.batfilter)
	c:RegisterEffect(e2)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件的判定值设为“只能用融合召唤方式才能特殊召唤”，限制其他特殊召唤方式。
	e3:SetValue(aux.fuslimit)
	c:RegisterEffect(e3)
end
-- 判断战斗对象的属性是否为暗、地、水、炎、风中的一种（0x2f为这些属性位），用于决定是否免疫战斗破坏。
function c99267150.batfilter(e,c)
	return c:IsAttribute(0x2f)
end
