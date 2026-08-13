--聖騎士ガウェイン
-- 效果：
-- 自己场上有光属性的通常怪兽存在的场合，这张卡可以从手卡表侧守备表示特殊召唤。
function c19680539.initial_effect(c)
	-- 自己场上有光属性的通常怪兽存在的场合，这张卡可以从手卡表侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_SPSUM_PARAM)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c19680539.spcon)
	c:RegisterEffect(e1)
end
-- 筛选条件：判断卡片是否为表侧表示、光属性、通常怪兽，用于检索场上满足发动前提的怪兽。
function c19680539.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 规则特殊召唤的条件：若c为空则视为满足条件；否则需要控制者场上有空余的主要怪兽区，且存在表侧表示的光属性通常怪兽，才能从手卡表侧守备表示特殊召唤。
function c19680539.spcon(e,c)
	if c==nil then return true end
	-- 检查该卡控制者场上是否有可用的主要怪兽区空位，确保特殊召唤后有格子。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查该卡控制者场上是否存在至少1张满足filter条件的表侧表示光属性通常怪兽。
		Duel.IsExistingMatchingCard(c19680539.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
