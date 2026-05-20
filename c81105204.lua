--BF－残夜のクリス
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：自己场上有「黑羽-残夜之波刃剑鸟」以外的「黑羽」怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：场上的这张卡1回合只有1次不会被魔法·陷阱卡的效果破坏。
function c81105204.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有「黑羽-残夜之波刃剑鸟」以外的「黑羽」怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,81105204+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c81105204.spcon)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡1回合只有1次不会被魔法·陷阱卡的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetCountLimit(1)
	e2:SetValue(c81105204.valcon)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「黑羽-残夜之波刃剑鸟」以外的「黑羽」怪兽
function c81105204.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x33) and not c:IsCode(81105204)
end
-- 特殊召唤规则的判定条件：自身控制者的怪兽区域有空位，且自己场上存在满足过滤条件的怪兽
function c81105204.spcon(e,c)
	if c==nil then return true end
	-- 检查这张卡的控制者的主要怪兽区域是否有可用的空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1张表侧表示的「黑羽-残夜之波刃剑鸟」以外的「黑羽」怪兽
		and Duel.IsExistingMatchingCard(c81105204.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 破坏抗性的适用条件：破坏原因是由魔法或陷阱卡的效果造成的
function c81105204.valcon(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
