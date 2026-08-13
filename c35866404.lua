--グランドラン
-- 效果：
-- 对方场上有超量怪兽存在的场合，这张卡可以从手卡表侧攻击表示特殊召唤。
function c35866404.initial_effect(c)
	-- 对方场上有超量怪兽存在的场合，这张卡可以从手卡表侧攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_SPSUM_PARAM)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP_ATTACK,0)
	e1:SetCondition(c35866404.spcon)
	c:RegisterEffect(e1)
end
-- 定义过滤条件：用于筛选对方场上表侧表示的超量怪兽。
function c35866404.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 规则特殊召唤的召唤条件：当c为nil时表示可进行此类召唤的询问；否则需要自身主要怪兽区有空位，且对方场上有表侧表示的超量怪兽。
function c35866404.spcon(e,c)
	if c==nil then return true end
	-- 检查这张卡的控制者的主要怪兽区域是否有空位，确保可以放置特殊召唤的怪兽。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查对方场上是否存在至少1张表侧表示的超量怪兽，以符合特殊召唤条件。
		and Duel.IsExistingMatchingCard(c35866404.filter,c:GetControler(),0,LOCATION_MZONE,1,nil)
end
