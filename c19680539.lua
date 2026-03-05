--聖騎士ガウェイン
-- 效果：
-- 自己场上有光属性的通常怪兽存在的场合，这张卡可以从手卡表侧守备表示特殊召唤。
function c19680539.initial_effect(c)
	-- 效果原文内容：自己场上有光属性的通常怪兽存在的场合，这张卡可以从手卡表侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_SPSUM_PARAM)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c19680539.spcon)
	c:RegisterEffect(e1)
end
-- 检索满足条件的场上表侧表示的通常怪兽，且属性为光的怪兽
function c19680539.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 检查特殊召唤的条件是否满足，包括是否有足够的怪兽区域和是否存在符合条件的光属性通常怪兽
function c19680539.spcon(e,c)
	if c==nil then return true end
	-- 判断玩家的怪兽区域是否有空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查玩家场上是否存在至少1只满足filter条件的怪兽
		Duel.IsExistingMatchingCard(c19680539.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
