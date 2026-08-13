--勝利の導き手フレイヤ
-- 效果：
-- 自己场上有「胜利的引导者 芙蕾雅」以外的天使族怪兽表侧表示存在的场合，这张卡不能被选择作为攻击对象。只要这张卡在自己场上表侧表示存在，自己场上存在的天使族怪兽的攻击力·守备力上升400。
function c12398280.initial_effect(c)
	-- 只要这张卡在自己场上表侧表示存在，自己场上存在的天使族怪兽的攻击力·守备力上升400。
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
	-- 自己场上有「胜利的引导者 芙蕾雅」以外的天使族怪兽表侧表示存在的场合，这张卡不能被选择作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(c12398280.con)
	-- 设置“不能成为攻击对象”效果的判定函数（aux.imval1）：当其他怪兽选择攻击对象时，若该怪兽不免疫此效果，则不能选择这张卡。
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
end
-- 效果适用对象的过滤函数：攻击力·守备力上升效果只对天使族怪兽生效。
function c12398280.tg(e,c)
	return c:IsRace(RACE_FAIRY)
end
-- 筛选条件：怪兽为表侧表示、天使族、且卡名不是「胜利的引导者 芙蕾雅」，用于判断是否存在其他表侧表示天使族怪兽。
function c12398280.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY) and not c:IsCode(12398280)
end
-- 不能成为攻击对象效果的条件：以这张卡的控制者视角，检查其场上是否存在满足filter的“芙蕾雅以外的表侧表示天使族怪兽”。
function c12398280.con(e)
	local c=e:GetHandler()
	-- 调用Duel.IsExistingMatchingCard，检测控制者场上（主要怪兽区）是否存在至少1张满足filter的怪兽（排除效果持有者自身），返回布尔值作为条件判断结果。
	return Duel.IsExistingMatchingCard(c12398280.filter,c:GetControler(),LOCATION_MZONE,0,1,c)
end
