--深夜急行騎士ナイト・エクスプレス・ナイト
-- 效果：
-- 这张卡不能从卡组特殊召唤。
-- ①：这张卡可以不用解放作召唤。
-- ②：这张卡的①的方法召唤的这张卡的原本攻击力变成0。
function c51126152.initial_effect(c)
	-- 这张卡不能从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_DECK)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：这张卡可以不用解放作召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51126152,0))  --"不解放怪兽召唤"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(c51126152.ntcon)
	e2:SetOperation(c51126152.ntop)
	c:RegisterEffect(e2)
end
-- 判断召唤条件是否满足，即不需解放且等级不低于5且场上存在空位。
function c51126152.ntcon(e,c,minc)
	if c==nil then return true end
	-- 不需解放且等级不低于5且场上存在空位。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 设置效果处理函数，将原本攻击力设为0。
function c51126152.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 这张卡的①的方法召唤的这张卡的原本攻击力变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(0)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
