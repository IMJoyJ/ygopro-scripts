--勝利の導き手フレイヤ
-- 效果：
-- 自己场上有「胜利的引导者 芙蕾雅」以外的天使族怪兽表侧表示存在的场合，这张卡不能被选择作为攻击对象。只要这张卡在自己场上表侧表示存在，自己场上存在的天使族怪兽的攻击力·守备力上升400。
function c12398280.initial_effect(c)
	-- 自己场上有「胜利的引导者 芙蕾雅」以外的天使族怪兽表侧表示存在的场合，这张卡不能被选择作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTarget(c12398280.tg)
	e1:SetValue(400)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- 只要这张卡在自己场上表侧表示存在，自己场上存在的天使族怪兽的攻击力·守备力上升400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(c12398280.con)
	-- 设置效果值为过滤函数aux.imval1，用于判断目标是否能成为攻击对象
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断目标是否为天使族怪兽
function c12398280.tg(e,c)
	return c:IsRace(RACE_FAIRY)
end
-- 过滤函数，用于判断场上的天使族怪兽是否不是芙蕾雅
function c12398280.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY) and not c:IsCode(12398280)
end
-- 条件函数，用于判断自己场上是否存在其他天使族怪兽
function c12398280.con(e)
	local c=e:GetHandler()
	-- 检查以自己为玩家，在主要怪兽区是否存在至少1张满足filter条件的卡
	return Duel.IsExistingMatchingCard(c12398280.filter,c:GetControler(),LOCATION_MZONE,0,1,c)
end
