--ラヴァル・コアトル
-- 效果：
-- 自己墓地有名字带有「熔岩」的怪兽3种类以上存在的场合，这张卡可以从手卡特殊召唤。
function c45439263.initial_effect(c)
	-- 自己墓地有名字带有「熔岩」的怪兽3种类以上存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c45439263.spcon)
	c:RegisterEffect(e1)
end
-- 该函数是这张卡通过规则效果（EFFECT_SPSUMMON_PROC）从手卡进行无种类限制特殊召唤的条件判定：当c为nil时表示询问该特殊召唤手续本身是否可用，返回true；否则需要己方主要怪兽区有空位，并且自己墓地中「熔岩」怪兽的种类数不少于3。
function c45439263.spcon(e,c)
	if c==nil then return true end
	-- 检查这张卡的控制者是否拥有可用的主要怪兽区域空位；若没有空位则不能进行特殊召唤。
	if Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)<=0 then return false end
	-- 统计这张卡控制者墓地中所有卡名带有「熔岩」（0x39）的怪兽，按不同卡名计数，判断种类数是否达到3种或以上；达到3种以上则满足特殊召唤条件。
	return Duel.GetMatchingGroup(Card.IsSetCard,c:GetControler(),LOCATION_GRAVE,0,nil,0x39):GetClassCount(Card.GetCode)>=3
end
