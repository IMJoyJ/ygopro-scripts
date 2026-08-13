--ガガガクラーク
-- 效果：
-- ①：自己场上有「我我我书记」以外的「我我我」怪兽存在的场合，这张卡可以从手卡特殊召唤。
function c44250812.initial_effect(c)
	-- ①：自己场上有「我我我书记」以外的「我我我」怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c44250812.spcon)
	c:RegisterEffect(e1)
end
-- 定义筛选条件：怪兽须表侧表示、属于「我我我」字段（0x54）、且不是「我我我书记」自身。
function c44250812.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x54) and not c:IsCode(44250812)
end
-- 特殊召唤规则的条件判定：当请求召唤的卡为nil时直接允许；否则须我方主要怪兽区有空位，且自己场上有满足filter的「我我我」怪兽存在。
function c44250812.spcon(e,c)
	if c==nil then return true end
	-- 检查我方主要怪兽区是否存在空余格子，以满足特殊召唤所需的场地条件。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查自己场上是否存在至少1张满足filter条件的「我我我」怪兽（表侧表示、是「我我我」字段、且不是本卡）。
		Duel.IsExistingMatchingCard(c44250812.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
