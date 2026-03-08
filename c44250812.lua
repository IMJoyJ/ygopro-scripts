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
-- 过滤函数，用于判断场上是否存在满足条件的「我我我」怪兽（表侧表示且不是「我我我书记」）
function c44250812.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x54) and not c:IsCode(44250812)
end
-- 特殊召唤条件函数，判断是否满足特殊召唤的条件
function c44250812.spcon(e,c)
	if c==nil then return true end
	-- 检查玩家场上是否有可用的怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查玩家场上是否存在至少1张满足filter条件的怪兽
		Duel.IsExistingMatchingCard(c44250812.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
