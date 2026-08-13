--ハンター・アウル
-- 效果：
-- 自己场上表侧表示存在的风属性怪兽每有1只，这张卡的攻击力上升500。此外，只要自己场上有其他的风属性怪兽表侧表示存在，对方不能选择这张卡作为攻击对象。
function c51962254.initial_effect(c)
	-- 此外，只要自己场上有其他的风属性怪兽表侧表示存在，对方不能选择这张卡作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c51962254.atcon)
	-- 设置该效果的具体判定逻辑：只要攻击怪兽不免疫此效果，就不能选择这张卡作为攻击对象。
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- 自己场上表侧表示存在的风属性怪兽每有1只，这张卡的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c51962254.upval)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断怪兽是否为表侧表示且风属性，用于检索场上符合条件的风属性怪兽。
function c51962254.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 这是“不能成为攻击对象”效果的适用条件：自己场上有其他表侧表示的风属性怪兽时成立。
function c51962254.atcon(e)
	-- 调用 Duel.IsExistingMatchingCard 检查自己场上是否存在至少1张除自身以外的表侧风属性怪兽，存在则条件成立。
	return Duel.IsExistingMatchingCard(c51962254.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- 攻击力上升数值的计算函数：统计自己场上表侧表示的风属性怪兽数量（包括自身），每只提供500点攻击力。
function c51962254.upval(e,c)
	-- 返回自己场上表侧表示的风属性怪兽数量乘以500（数量包括自身），作为攻击力上升数值。
	return Duel.GetMatchingGroupCount(c51962254.upfilter,c:GetControler(),LOCATION_MZONE,0,nil)*500
end
-- 过滤函数：判断怪兽是否为表侧表示且风属性，供攻击力上升效果计算数量使用。
function c51962254.upfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND)
end
