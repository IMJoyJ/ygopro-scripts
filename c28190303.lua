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
-- 检查场上是否只有1只其他黑羽怪兽，满足条件时可以特殊召唤
function c28190303.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断召唤玩家的怪兽区域是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	-- 获取场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	return g:GetCount()==1 and tc:IsSetCard(0x33) and not tc:IsCode(28190303)
end
-- 判断破坏原因是否为战斗破坏
function c28190303.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
