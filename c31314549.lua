--RR－シンギング・レイニアス
-- 效果：
-- 「急袭猛禽-鸣啭伯劳」的①的方法的特殊召唤1回合只能有1次。
-- ①：自己场上有超量怪兽存在的场合，这张卡可以从手卡特殊召唤。
function c31314549.initial_effect(c)
	-- 「急袭猛禽-鸣啭伯劳」的①的方法的特殊召唤1回合只能有1次。①：自己场上有超量怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,31314549+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c31314549.spcon)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断怪兽是否满足表侧表示且为超量怪兽，用于确认“自己场上有超量怪兽存在”的条件。
function c31314549.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 特殊召唤规则的条件函数：当c为nil时返回true表示允许询问；当c为实际要特殊召唤的这张卡时，必须满足自己主要怪兽区有空位且自己场上有表侧表示的超量怪兽，才能通过①效果从手卡特殊召唤。
function c31314549.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的主要怪兽区域空格，供这张卡从手卡特殊召唤。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1张表侧表示的超量怪兽，满足“自己场上有超量怪兽存在的场合”这一条件。
		and Duel.IsExistingMatchingCard(c31314549.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
