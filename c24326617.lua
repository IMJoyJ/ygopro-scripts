--氷帝家臣エッシャー
-- 效果：
-- ①：对方的魔法与陷阱区域有卡2张以上存在的场合，这张卡可以从手卡特殊召唤。
function c24326617.initial_effect(c)
	-- 效果原文内容：①：对方的魔法与陷阱区域有卡2张以上存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c24326617.spcon)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断魔法与陷阱区域中的卡是否在场地区（序号小于5）
function c24326617.filter(c)
	return c:GetSequence()<5
end
-- 特殊召唤条件函数，检查是否满足特殊召唤的条件
function c24326617.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断召唤玩家的怪兽区域是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断对方魔法与陷阱区域是否存在至少2张满足条件的卡
		and Duel.IsExistingMatchingCard(c24326617.filter,tp,0,LOCATION_SZONE,2,nil)
end
