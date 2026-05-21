--フォトン・アドバンサー
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：场上有「光子」怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：场上有这张卡以外的「光子」怪兽存在的场合，这张卡的攻击力上升1000。
function c98881931.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：场上有「光子」怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,98881931+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c98881931.sprcon)
	c:RegisterEffect(e1)
	-- ②：场上有这张卡以外的「光子」怪兽存在的场合，这张卡的攻击力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c98881931.atkcon)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查卡片是否为表侧表示的「光子」怪兽
function c98881931.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x55)
end
-- 特殊召唤规则的条件函数：检查自身怪兽区域是否有空位，且场上是否存在「光子」怪兽
function c98881931.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自身怪兽区域是否有可用的空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方场上是否存在至少1只表侧表示的「光子」怪兽
		and Duel.IsExistingMatchingCard(c98881931.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 条件函数：检查是否由魔法·陷阱卡的效果造成
function c98881931.valcon(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 攻击力上升效果的条件函数：检查场上是否存在这张卡以外的「光子」怪兽
function c98881931.atkcon(e)
	-- 检查双方场上是否存在至少1只除这张卡以外的表侧表示「光子」怪兽
	return Duel.IsExistingMatchingCard(c98881931.filter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler())
end
