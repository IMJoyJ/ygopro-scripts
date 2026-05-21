--ガーディアン・ケースト
-- 效果：
-- 当自己场上存在「静寂之杖-波纹」时才能召唤·反转召唤·特殊召唤。这张卡不受魔法效果影响。这张卡不能成为对方的攻击对象。
function c9633505.initial_effect(c)
	-- 当自己场上存在「静寂之杖-波纹」时才能召唤
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c9633505.sumcon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	-- 当自己场上存在「静寂之杖-波纹」时才能……特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	e3:SetValue(c9633505.sumlimit)
	c:RegisterEffect(e3)
	-- 这张卡不受魔法效果影响。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(c9633505.efilter)
	c:RegisterEffect(e4)
	-- 这张卡不能成为对方的攻击对象。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
-- 过滤条件：场上表侧表示的「静寂之杖-波纹」
function c9633505.cfilter(c)
	return c:IsFaceup() and c:IsCode(95515060)
end
-- 召唤与反转召唤限制的条件函数：自己场上不存在表侧表示的「静寂之杖-波纹」时无法召唤
function c9633505.sumcon(e)
	-- 检查自己场上是否不存在表侧表示的「静寂之杖-波纹」
	return not Duel.IsExistingMatchingCard(c9633505.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- 特殊召唤限制的条件函数：只有自己场上存在表侧表示的「静寂之杖-波纹」时才能特殊召唤
function c9633505.sumlimit(e,se,sp,st,pos,tp)
	-- 检查自己场上是否存在表侧表示的「静寂之杖-波纹」
	return Duel.IsExistingMatchingCard(c9633505.cfilter,sp,LOCATION_ONFIELD,0,1,nil)
end
-- 免疫效果的过滤函数：判定效果是否为魔法卡效果
function c9633505.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL)
end
