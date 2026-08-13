--氷帝家臣エッシャー
-- 效果：
-- ①：对方的魔法与陷阱区域有卡2张以上存在的场合，这张卡可以从手卡特殊召唤。
function c24326617.initial_effect(c)
	-- ①：对方的魔法与陷阱区域有卡2张以上存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c24326617.spcon)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选出位于对方魔法与陷阱区域且格子序号小于5的卡（即通常的魔陷区，场地魔法格序号为5，灵摆区域序号为6/7，均不计入）。
function c24326617.filter(c)
	return c:GetSequence()<5
end
-- 特殊召唤规则发动条件：c为nil时视为规则允许；否则需要我方怪兽区有空位，且对方魔陷区存在2张以上符合filter的卡。
function c24326617.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查我方主要怪兽区是否有可用空格，确保满足特殊召唤所需空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方魔法与陷阱区域是否存在至少2张符合条件的卡（通过filter排除场地魔法区和灵摆区域）。
		and Duel.IsExistingMatchingCard(c24326617.filter,tp,0,LOCATION_SZONE,2,nil)
end
