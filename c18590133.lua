--キングゴブリン
-- 效果：
-- 若自己场上有除这张卡以外的恶魔族怪兽存在，则这张卡不能被攻击。这张卡的攻击力·守备力成为与全场除这张卡以外的恶魔族怪兽数量×1000点等同的数值。
function c18590133.initial_effect(c)
	-- 若自己场上有除这张卡以外的恶魔族怪兽存在，则这张卡不能被攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(c18590133.ccon)
	-- 设置效果值为aux.imval1函数，用于判断是否能成为攻击对象
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- 这张卡的攻击力·守备力成为与全场除这张卡以外的恶魔族怪兽数量×1000点等同的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SET_ATTACK)
	e2:SetValue(c18590133.val)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断是否为表侧表示的恶魔族怪兽
function c18590133.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND)
end
-- 条件函数，用于判断自己场上有除这张卡以外的恶魔族怪兽存在
function c18590133.ccon(e)
	-- 检查以自己为玩家，在自己的主要怪兽区（包括额外怪兽区）是否存在至少1张满足filter条件且不等于自身效果的卡
	return Duel.IsExistingMatchingCard(c18590133.filter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- 数值函数，用于计算攻击力和守备力的数值
function c18590133.val(e,c)
	-- 返回以自身为玩家，在自己的主要怪兽区（包括额外怪兽区）满足filter条件的卡的数量，并乘以1000
	return Duel.GetMatchingGroupCount(c18590133.filter,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,c)*1000
end
