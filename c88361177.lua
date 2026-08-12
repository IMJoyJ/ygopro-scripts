--ドラグニティ－アングス
-- 效果：
-- 这张卡有名字带有「龙骑兵团」的龙族怪兽装备的场合，这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c88361177.initial_effect(c)
	-- 这张卡有名字带有「龙骑兵团」的龙族怪兽装备的场合，这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetCondition(c88361177.pcon)
	c:RegisterEffect(e1)
end
-- 过滤满足表侧表示、卡名含有「龙骑兵团」且是龙族的卡片
function c88361177.pfilter(c)
	return c:IsSetCard(0x29) and c:IsRace(RACE_DRAGON) and c:IsFaceup()
end
-- 检查自身装备的卡片中是否存在至少1张满足过滤条件的卡
function c88361177.pcon(e)
	return e:GetHandler():GetEquipGroup():IsExists(c88361177.pfilter,1,nil)
end
