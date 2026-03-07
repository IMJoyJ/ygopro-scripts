--RR－シンギング・レイニアス
-- 效果：
-- 「急袭猛禽-鸣啭伯劳」的①的方法的特殊召唤1回合只能有1次。
-- ①：自己场上有超量怪兽存在的场合，这张卡可以从手卡特殊召唤。
function c31314549.initial_effect(c)
	-- ①：自己场上有超量怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,31314549+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c31314549.spcon)
	c:RegisterEffect(e1)
end
-- 过滤场上存在的表侧表示的超量怪兽
function c31314549.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 检查特殊召唤条件是否满足：场上存在超量怪兽且有空位
function c31314549.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否存在可用怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家场上是否存在至少1只表侧表示的超量怪兽
		and Duel.IsExistingMatchingCard(c31314549.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
