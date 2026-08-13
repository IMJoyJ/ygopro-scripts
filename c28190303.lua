--BF－白夜のグラディウス
-- 效果：
-- ①：自己场上的表侧表示怪兽只有「黑羽-白夜之短剑鸟」以外的「黑羽」怪兽1只的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡1回合只有1次不会被战斗破坏。
function c28190303.initial_effect(c)
	-- ①：自己场上的表侧表示怪兽只有「黑羽-白夜之短剑鸟」以外的「黑羽」怪兽1只的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c28190303.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡1回合只有1次不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetCountLimit(1)
	e2:SetValue(c28190303.valcon)
	c:RegisterEffect(e2)
end
-- 作为特殊召唤规则的条件判定，确认这张卡能否从手卡特殊召唤：需要自己场上表侧表示怪兽恰好有1只「黑羽」怪兽，且该怪兽不能是「黑羽-白夜之短剑鸟」自身，同时满足怪兽区空格条件。
function c28190303.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在可用的主要怪兽区空格，若没有空格则无法进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	-- 检索自己场上全部表侧表示怪兽并组成集合，用于判断场上表侧表示怪兽的数量和具体条件。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	return g:GetCount()==1 and tc:IsSetCard(0x33) and not tc:IsCode(28190303)
end
-- 破坏抗性判定函数：仅当破坏原因为战斗破坏时返回真，使②效果的“1回合1次不会被战斗破坏”适用。
function c28190303.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
