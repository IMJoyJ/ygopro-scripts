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
-- 特殊召唤规则的条件判定：若c为nil则视为满足；否则需要己方主要怪兽区有空位且能够支付2000基本分，才允许用此规则特殊召唤。
function c44682448.spcon(e,c)
	if c==nil then return true end
	-- 检查该卡的控制者的主要怪兽区是否存在可用空格。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查该卡的控制者能否支付2000基本分。
		Duel.CheckLPCost(c:GetControler(),2000)
end
-- 特殊召唤规则的处理：实际支付2000基本分，完成特殊召唤手续。
function c44682448.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 扣除2000基本分作为特殊召唤的代价。
	Duel.PayLPCost(tp,2000)
end
-- 超量素材限制判定：若超量召唤的怪兽不是暗属性，则本卡不能作为其超量素材；即仅可用于暗属性怪兽的超量召唤。
function c44682448.xyzlimit(e,c)
	if not c then return false end
	return not c:IsAttribute(ATTRIBUTE_DARK)
end
