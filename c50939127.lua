--異次元竜 トワイライトゾーンドラゴン
-- 效果：
-- 这张卡不会被不指定对象的魔法、陷阱卡的效果破坏。这张卡不会被攻击力1900以下的怪兽战斗破坏。
function c50939127.initial_effect(c)
	-- 这张卡不会被不指定对象的魔法、陷阱卡的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(c50939127.ind1)
	c:RegisterEffect(e1)
	-- 这张卡不会被攻击力1900以下的怪兽战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(c50939127.ind2)
	c:RegisterEffect(e2)
end
-- 判断效果是否作用于魔法或陷阱卡且该效果未指定对象。
function c50939127.ind1(e,re,rp,c)
	return not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 判断自身攻击力是否低于1900。
function c50939127.ind2(e,c)
	return c:IsAttackBelow(1900)
end
