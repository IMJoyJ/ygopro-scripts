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
-- 过滤出表侧表示、属于「六武众」系列且不是自身卡名的怪兽，用于判断场上是否存在「真六武众-辉斩」以外的「六武众」怪兽。
function c49721904.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d) and not c:IsCode(49721904)
end
-- 作为手卡特殊召唤规则效果的条件，检查主要怪兽区有空位且自己场上有满足spfilter的「六武众」怪兽存在，决定这张卡能否从手卡特殊召唤。
function c49721904.spcon(e,c)
	if c==nil then return true end
	-- 检查这张卡的持有者场上是否有空余的主要怪兽区，用于特殊召唤。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在1张以上表侧表示的、卡名为「真六武众-辉斩」以外的「六武众」怪兽。
		and Duel.IsExistingMatchingCard(c49721904.spfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 过滤出表侧表示的「六武众」怪兽，用于判断自己场上怪兽数量和后续攻守提升的条件。
function c49721904.vfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d)
end
-- 攻击力·守备力上升效果的条件，检查这张卡以外是否存在2只以上表侧表示的「六武众」怪兽。
function c49721904.valcon(e)
	local c=e:GetHandler()
	-- 检查自己场上是否存在至少2只表侧表示的「六武众」怪兽，且不包含这张卡自身。
	return Duel.IsExistingMatchingCard(c49721904.vfilter,c:GetControler(),LOCATION_MZONE,0,2,c)
end
