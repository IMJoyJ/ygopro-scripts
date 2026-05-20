--限界竜シュヴァルツシルト
-- 效果：
-- ①：对方场上有攻击力2000以上的怪兽存在的场合，这张卡可以从手卡特殊召唤。
function c6930746.initial_effect(c)
	-- ①：对方场上有攻击力2000以上的怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c6930746.spcon)
	c:RegisterEffect(e1)
end
-- 过滤表侧表示且攻击力在2000以上的怪兽
function c6930746.filter(c)
	return c:IsFaceup() and c:IsAttackAbove(2000)
end
-- 判断这张卡从手卡特殊召唤的条件是否满足的函数
function c6930746.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自身场上是否有可以放置怪兽的空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方场上是否存在满足过滤条件（表侧表示且攻击力2000以上）的怪兽
		and Duel.IsExistingMatchingCard(c6930746.filter,tp,0,LOCATION_MZONE,1,nil)
end
