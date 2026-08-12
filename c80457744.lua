--ブースト・ウォリアー
-- 效果：
-- ①：自己场上有调整存在的场合，这张卡可以从手卡守备表示特殊召唤。
-- ②：只要这张卡在怪兽区域存在，自己场上的战士族怪兽的攻击力上升300。
function c80457744.initial_effect(c)
	-- ①：自己场上有调整存在的场合，这张卡可以从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_SPSUM_PARAM)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c80457744.spcon)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己场上的战士族怪兽的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	-- 设置效果的影响对象为战士族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_WARRIOR))
	e2:SetValue(300)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示的调整怪兽
function c80457744.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_TUNER)
end
-- 特殊召唤规则的判定条件：自身控制者的主要怪兽区域有空位，且我方场上存在表侧表示的调整怪兽
function c80457744.spcon(e,c)
	if c==nil then return true end
	-- 检查自身控制者的主要怪兽区域是否有可用的空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查我方场上是否存在至少1张满足过滤条件（表侧表示调整）的卡
		Duel.IsExistingMatchingCard(c80457744.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
