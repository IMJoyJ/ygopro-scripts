--デスサイクロン
-- 效果：
-- 这张卡被战斗破坏送去墓地时，场上表侧表示存在的风属性怪兽以外的怪兽全部破坏。
function c59235795.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，场上表侧表示存在的风属性怪兽以外的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59235795,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c59235795.condition)
	e1:SetTarget(c59235795.target)
	e1:SetOperation(c59235795.operation)
	c:RegisterEffect(e1)
end
-- 检查发动条件：自身是否在墓地且是被战斗破坏
function c59235795.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤条件：里侧表示的怪兽，或者表侧表示且非风属性的怪兽（即风属性怪兽以外的怪兽）
function c59235795.filter(c)
	return (c:IsFacedown() or c:GetAttribute()~=ATTRIBUTE_WIND)
end
-- 效果发动的目标：必发效果直接返回true，并获取符合条件的怪兽组，设置破坏的操作信息
function c59235795.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上所有符合过滤条件的怪兽组
	local g=Duel.GetMatchingGroup(c59235795.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置效果处理信息：破坏上述获取的怪兽组
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：重新获取当前场上符合过滤条件的怪兽并将其全部破坏
function c59235795.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 重新获取当前双方场上所有符合过滤条件的怪兽组
	local g=Duel.GetMatchingGroup(c59235795.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将这些怪兽因效果破坏
	Duel.Destroy(g,REASON_EFFECT)
end
