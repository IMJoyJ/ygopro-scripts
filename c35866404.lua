--グランドラン
-- 效果：
-- 对方场上有超量怪兽存在的场合，这张卡可以从手卡表侧攻击表示特殊召唤。
function c35866404.initial_effect(c)
	-- 卡片效果原文：对方场上有超量怪兽存在的场合，这张卡可以从手卡表侧攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_SPSUM_PARAM)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP_ATTACK,0)
	e1:SetCondition(c35866404.spcon)
	c:RegisterEffect(e1)
end
-- 检索满足条件的场上表侧表示的超量怪兽
function c35866404.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 检查特殊召唤条件是否满足：玩家场上存在可用区域且对方场上存在超量怪兽
function c35866404.spcon(e,c)
	if c==nil then return true end
	-- 检查玩家场上是否存在可用怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查对方场上是否存在至少1只超量怪兽
		and Duel.IsExistingMatchingCard(c35866404.filter,c:GetControler(),0,LOCATION_MZONE,1,nil)
end
