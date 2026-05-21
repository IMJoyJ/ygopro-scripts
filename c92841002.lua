--幻水龍
-- 效果：
-- 自己场上有地属性怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法的「幻水龙」的特殊召唤1回合只能有1次。
function c92841002.initial_effect(c)
	-- 自己场上有地属性怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法的「幻水龙」的特殊召唤1回合只能有1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,92841002+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c92841002.spcon)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的地属性怪兽
function c92841002.spfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 特殊召唤规则的判定条件：自身控制者的怪兽区域有空位，且自己场上存在表侧表示的地属性怪兽
function c92841002.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查当前玩家的怪兽区域是否有可用的空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1张满足过滤条件（表侧表示地属性）的怪兽
		and Duel.IsExistingMatchingCard(c92841002.spfilter,tp,LOCATION_MZONE,0,1,nil)
end
