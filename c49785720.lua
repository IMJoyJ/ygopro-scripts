--機炎星－ゴヨウテ
-- 效果：
-- 自己场上有名字带有「炎舞」的魔法·陷阱卡存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
function c49785720.initial_effect(c)
	-- 效果原文：自己场上有名字带有「炎舞」的魔法·陷阱卡存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c49785720.spcon)
	c:RegisterEffect(e1)
end
-- 检索满足条件的表侧表示的、卡名含「炎舞」的魔法或陷阱卡
function c49785720.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 检查是否满足特殊召唤条件：场上存在可用区域、己方怪兽区为空、己方魔法陷阱区存在符合条件的卡
function c49785720.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断己方主要怪兽区是否有可用空间
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断己方主要怪兽区是否没有怪兽
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 检查己方魔法陷阱区是否存在至少1张满足filter条件的卡
		and Duel.IsExistingMatchingCard(c49785720.filter,tp,LOCATION_SZONE,0,1,nil)
end
