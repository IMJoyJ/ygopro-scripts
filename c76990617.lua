--幻奏の音女ソナタ
-- 效果：
-- ①：自己场上有「幻奏」怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：只要特殊召唤的这张卡在怪兽区域存在，自己场上的天使族怪兽的攻击力·守备力上升500。
function c76990617.initial_effect(c)
	-- ①：自己场上有「幻奏」怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c76990617.spcon)
	c:RegisterEffect(e1)
	-- ②：只要特殊召唤的这张卡在怪兽区域存在，自己场上的天使族怪兽的攻击力·守备力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果影响的目标为天使族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_FAIRY))
	e2:SetValue(500)
	e2:SetCondition(c76990617.tgcon)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的「幻奏」怪兽
function c76990617.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9b)
end
-- 特殊召唤规则的判定条件
function c76990617.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在表侧表示的「幻奏」怪兽
		and Duel.IsExistingMatchingCard(c76990617.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 检查自身是否为特殊召唤
function c76990617.tgcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
