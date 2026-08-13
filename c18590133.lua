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
	-- 设置“不能成为攻击对象”的判定值为aux.imval1：若该卡不免疫此效果，则不能成为攻击对象。
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
-- 过滤条件：表侧表示且种族为恶魔族的怪兽。
function c18590133.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND)
end
-- 条件判断：自己场上是否存在除这张卡以外的恶魔族怪兽（至少1只）。
function c18590133.ccon(e)
	-- 检查以这张卡控制者视角看，其怪兽区是否存在满足过滤条件且不是这张卡自身的怪兽。
	return Duel.IsExistingMatchingCard(c18590133.filter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- 计算这张卡的攻击力/守备力数值：全场除这张卡以外的表侧表示恶魔族怪兽数量×1000。
function c18590133.val(e,c)
	-- 统计双方场上除这张卡自身以外满足恶魔族表侧表示条件的怪兽数量，并乘以1000作为设定值。
	return Duel.GetMatchingGroupCount(c18590133.filter,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,c)*1000
end
