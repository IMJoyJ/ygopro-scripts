--極星將テュール
-- 效果：
-- 场上没有这张卡以外的名字带有「极星」的怪兽表侧表示存在的场合，这张卡破坏。只要这张卡在场上表侧表示存在，对方不能选择「极星将 提尔」以外的名字带有「极星」的怪兽作为攻击对象。
function c2333365.initial_effect(c)
	-- 场上没有这张卡以外的名字带有「极星」的怪兽表侧表示存在的场合，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetCondition(c2333365.descon)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上表侧表示存在，对方不能选择「极星将 提尔」以外的名字带有「极星」的怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetValue(c2333365.atlimit)
	c:RegisterEffect(e2)
end
-- 过滤出表侧表示且名字带有「极星」的怪兽，用于后续判定是否存在这张卡以外的极星怪兽。
function c2333365.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x42)
end
-- 判定场上是否不存在这张卡以外的表侧表示名字带有「极星」的怪兽；若不存在则满足自我破坏条件。
function c2333365.descon(e)
	-- 检查双方怪兽区域是否存在满足filter条件且不是这张卡自身的表侧表示「极星」怪兽；若不存在则返回true。
	return not Duel.IsExistingMatchingCard(c2333365.filter,0,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler())
end
-- 作为攻击对象限制效果的判定函数：若攻击对象是表侧表示、卡名不是「极星将 提尔」且名字带有「极星」的怪兽，则对方不能将其选为攻击对象。
function c2333365.atlimit(e,c)
	return c:IsFaceup() and not c:IsCode(2333365) and c:IsSetCard(0x42)
end
