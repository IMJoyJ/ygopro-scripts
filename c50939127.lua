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
-- 该判断函数用于效果破坏免疫：当来袭效果不取对象（不具有EFFECT_FLAG_CARD_TARGET标志）且为魔法/陷阱卡效果时返回true，使此卡不会被其效果破坏。
function c50939127.ind1(e,re,rp,c)
	return not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 该判断函数用于战斗破坏免疫：当与这张卡进行战斗的怪兽攻击力在1900以下时返回true，使此卡不会被该怪兽战斗破坏。
function c50939127.ind2(e,c)
	return c:IsAttackBelow(1900)
end
