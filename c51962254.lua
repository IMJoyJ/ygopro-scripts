--ハンター・アウル
-- 效果：
-- 自己场上表侧表示存在的风属性怪兽每有1只，这张卡的攻击力上升500。此外，只要自己场上有其他的风属性怪兽表侧表示存在，对方不能选择这张卡作为攻击对象。
function c51962254.initial_effect(c)
	-- 自己场上表侧表示存在的风属性怪兽每有1只，这张卡的攻击力上升500。此外，只要自己场上有其他的风属性怪兽表侧表示存在，对方不能选择这张卡作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c51962254.atcon)
	-- 设置效果值为aux.imval1函数，用于判断是否不会成为攻击对象
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- 自己场上表侧表示存在的风属性怪兽每有1只，这张卡的攻击力上升500。此外，只要自己场上有其他的风属性怪兽表侧表示存在，对方不能选择这张卡作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c51962254.upval)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查一张卡是否为表侧表示且属性为风
function c51962254.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 条件函数：判断自己场上是否存在其他表侧表示的风属性怪兽
function c51962254.atcon(e)
	-- 检查以当前玩家来看，主要怪兽区是否存在至少1张满足cfilter条件的卡
	return Duel.IsExistingMatchingCard(c51962254.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- 计算攻击力提升值：统计己方场上的风属性表侧表示怪兽数量并乘以500
function c51962254.upval(e,c)
	-- 获取己方场上满足upfilter条件的卡的数量，并乘以500作为攻击力提升值
	return Duel.GetMatchingGroupCount(c51962254.upfilter,c:GetControler(),LOCATION_MZONE,0,nil)*500
end
-- 过滤函数：检查一张卡是否为表侧表示且属性为风
function c51962254.upfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND)
end
