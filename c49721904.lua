--真六武衆－キザン
-- 效果：
-- ①：自己场上有「真六武众-辉斩」以外的「六武众」怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：自己场上有这张卡以外的「六武众」怪兽2只以上存在的场合，这张卡的攻击力·守备力上升300。
function c49721904.initial_effect(c)
	-- ①：自己场上有「真六武众-辉斩」以外的「六武众」怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c49721904.spcon)
	c:RegisterEffect(e1)
	-- ②：自己场上有这张卡以外的「六武众」怪兽2只以上存在的场合，这张卡的攻击力·守备力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c49721904.valcon)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否存在满足条件的「六武众」怪兽（不包括辉斩自身）
function c49721904.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d) and not c:IsCode(49721904)
end
-- 特殊召唤条件函数，检查是否满足特殊召唤的条件
function c49721904.spcon(e,c)
	if c==nil then return true end
	-- 检查玩家场上是否有足够的怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查玩家场上是否存在至少1只满足条件的「六武众」怪兽（不包括自身）
		and Duel.IsExistingMatchingCard(c49721904.spfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于判断场上是否存在满足条件的「六武众」怪兽
function c49721904.vfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d)
end
-- 攻击力守备力上升效果的触发条件函数，检查是否满足效果发动条件
function c49721904.valcon(e)
	local c=e:GetHandler()
	-- 检查玩家场上是否存在至少2只满足条件的「六武众」怪兽
	return Duel.IsExistingMatchingCard(c49721904.vfilter,c:GetControler(),LOCATION_MZONE,0,2,c)
end
