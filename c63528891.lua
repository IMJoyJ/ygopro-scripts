--バックアップ・セクレタリー
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：自己场上有电子界族怪兽存在的场合，这张卡可以从手卡特殊召唤。
function c63528891.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有电子界族怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63528891,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,63528891+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c63528891.spcon)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示的电子界族怪兽
function c63528891.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE)
end
-- 特殊召唤规则的条件：怪兽区域有空位且自己场上存在电子界族怪兽
function c63528891.spcon(e,c)
	if c==nil then return true end
	-- 检查自身控制者的主要怪兽区域是否有可用的空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1只表侧表示的电子界族怪兽
		and Duel.IsExistingMatchingCard(c63528891.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
