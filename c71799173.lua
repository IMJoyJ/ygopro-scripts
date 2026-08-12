--ガーディアン・オブ・オーダー
-- 效果：
-- 自己场上有光属性怪兽表侧表示2只以上存在的场合，这张卡可以从手卡特殊召唤。「秩序守护者」在自己场上只能有1只表侧表示存在。
function c71799173.initial_effect(c)
	c:SetUniqueOnField(1,0,71799173)
	-- 自己场上有光属性怪兽表侧表示2只以上存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c71799173.spcon)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示且是光属性的怪兽
function c71799173.spfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 特殊召唤规则的条件：怪兽区域有空位，且自己场上存在2只以上的表侧表示光属性怪兽
function c71799173.spcon(e,c)
	if c==nil then return true end
	-- 检查自身控制者的怪兽区域是否有可用的空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少2只满足过滤条件（表侧表示且为光属性）的怪兽
		and	Duel.IsExistingMatchingCard(c71799173.spfilter,c:GetControler(),LOCATION_MZONE,0,2,nil)
end
