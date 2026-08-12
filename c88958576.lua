--ラヴァルバーナー
-- 效果：
-- 自己墓地有名字带有「熔岩」的怪兽3种类以上存在的场合，这张卡可以从手卡特殊召唤。
function c88958576.initial_effect(c)
	-- 自己墓地有名字带有「熔岩」的怪兽3种类以上存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c88958576.spcon)
	c:RegisterEffect(e1)
end
-- 特殊召唤规则的条件判定函数，检查怪兽区空位及墓地「熔岩」怪兽种类数是否满足要求
function c88958576.spcon(e,c)
	if c==nil then return true end
	-- 检查当前控制者的怪兽区域是否有空位，若无空位则无法特殊召唤
	if Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)<=0 then return false end
	-- 获取自己墓地中所有名字带有「熔岩」的卡片
	local g=Duel.GetMatchingGroup(Card.IsSetCard,c:GetControler(),LOCATION_GRAVE,0,nil,0x39)
	local ct=g:GetClassCount(Card.GetCode)
	return ct>=3
end
