--ガーベージ・ロード
-- 效果：
-- 这张卡可以支付2000基本分，从手卡特殊召唤。把这张卡作为超量素材的场合，不是暗属性怪兽的超量召唤不能使用。
function c44682448.initial_effect(c)
	-- 这张卡可以支付2000基本分，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c44682448.spcon)
	e1:SetOperation(c44682448.spop)
	c:RegisterEffect(e1)
	-- 把这张卡作为超量素材的场合，不是暗属性怪兽的超量召唤不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e2:SetValue(c44682448.xyzlimit)
	c:RegisterEffect(e2)
end
-- 检查召唤条件是否满足，包括场上是否有空位和是否能支付2000基本分。
function c44682448.spcon(e,c)
	if c==nil then return true end
	-- 检查召唤者控制者场上怪兽区域是否有空位。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查召唤者控制者是否能支付2000基本分。
		Duel.CheckLPCost(c:GetControler(),2000)
end
-- 支付2000基本分的特殊召唤操作。
function c44682448.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 支付2000基本分。
	Duel.PayLPCost(tp,2000)
end
-- 判断怪兽是否为暗属性，若不是则不能作为超量素材。
function c44682448.xyzlimit(e,c)
	if not c then return false end
	return not c:IsAttribute(ATTRIBUTE_DARK)
end
