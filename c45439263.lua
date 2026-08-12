--ラヴァル・コアトル
-- 效果：
-- 自己墓地有名字带有「熔岩」的怪兽3种类以上存在的场合，这张卡可以从手卡特殊召唤。
function c45439263.initial_effect(c)
	-- 创建一个字段效果，用于规定特殊召唤的条件
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c45439263.spcon)
	c:RegisterEffect(e1)
end
-- 判断特殊召唤的条件是否满足
function c45439263.spcon(e,c)
	if c==nil then return true end
	-- 检查召唤者控制者场上是否有足够的怪兽区域
	if Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)<=0 then return false end
	-- 检测自己墓地名字带有「熔岩」的怪兽数量是否达到3种以上
	return Duel.GetMatchingGroup(Card.IsSetCard,c:GetControler(),LOCATION_GRAVE,0,nil,0x39):GetClassCount(Card.GetCode)>=3
end
