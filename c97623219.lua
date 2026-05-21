--エレメント・ヴァルキリー
-- 效果：
-- 这只怪兽在场上有特定的属性的怪兽存在的场合，得到以下的效果。
-- ●炎属性：这张卡攻击力上升500。
-- ●水属性：这张卡的控制权不能变更。
function c97623219.initial_effect(c)
	-- 这只怪兽在场上有特定的属性的怪兽存在的场合，得到以下的效果。●炎属性：这张卡攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	e1:SetCondition(c97623219.atkcon)
	c:RegisterEffect(e1)
	-- 这只怪兽在场上有特定的属性的怪兽存在的场合，得到以下的效果。●水属性：这张卡的控制权不能变更。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	e2:SetCondition(c97623219.ctlcon)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查卡片是否为表侧表示且属于指定属性
function c97623219.filter(c,att)
	return c:IsFaceup() and c:IsAttribute(att)
end
-- 攻击力上升效果的启用条件：场上存在炎属性怪兽
function c97623219.atkcon(e)
	-- 检查双方场上是否存在至少1张表侧表示的炎属性怪兽
	return Duel.IsExistingMatchingCard(c97623219.filter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil,ATTRIBUTE_FIRE)
end
-- 控制权不能变更效果的启用条件：场上存在水属性怪兽
function c97623219.ctlcon(e)
	-- 检查双方场上是否存在至少1张表侧表示的水属性怪兽
	return Duel.IsExistingMatchingCard(c97623219.filter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil,ATTRIBUTE_WATER)
end
