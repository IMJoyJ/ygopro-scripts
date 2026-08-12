--クロクロークロウ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：自己场上有暗属性怪兽存在的场合，这张卡可以从手卡特殊召唤。
function c67692580.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有暗属性怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,67692580+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c67692580.spcon)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示的暗属性怪兽
function c67692580.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 特殊召唤规则的条件函数，判断怪兽区域是否有空位以及自己场上是否存在暗属性怪兽
function c67692580.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断当前玩家的主要怪兽区域是否有可用的空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己场上是否存在至少1只表侧表示的暗属性怪兽
		and Duel.IsExistingMatchingCard(c67692580.filter,tp,LOCATION_MZONE,0,1,nil)
end
