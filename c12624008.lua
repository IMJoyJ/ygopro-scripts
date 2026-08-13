--シャインスピリッツ
-- 效果：
-- 这张卡被战斗破坏送去墓地时，场上表侧表示存在的光属性怪兽以外的怪兽全部破坏。
function c12624008.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，场上表侧表示存在的光属性怪兽以外的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12624008,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c12624008.condition)
	e1:SetTarget(c12624008.target)
	e1:SetOperation(c12624008.operation)
	c:RegisterEffect(e1)
end
-- 判定触发条件：这张卡被战斗破坏后确实位于墓地，且破坏原因是战斗破坏。
function c12624008.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 筛选条件：场上表侧表示存在且属性不是光属性的怪兽，或里侧表示的怪兽（里侧表示怪兽属性未知，也视为非光属性怪兽以外）。
function c12624008.filter(c)
	return (c:IsFacedown() or c:GetAttribute()~=ATTRIBUTE_LIGHT)
end
-- 效果发动时仅需确认可发动，随后检索场上所有符合条件的怪兽，并设置将要破坏的操作信息。
function c12624008.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 在效果发动时，检索双方主要怪兽区中符合条件（非表侧光属性）的怪兽，得到对象集合g。
	local g=Duel.GetMatchingGroup(c12624008.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将本次连锁的操作信息登记为破坏效果，目标为刚检索到的怪兽集合g，数量为g的数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时再次检索场上符合条件的怪兽，并将其全部破坏。
function c12624008.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理阶段，重新获取双方主要怪兽区中符合条件（非表侧光属性）的怪兽，确保处理时仍存在的目标。
	local g=Duel.GetMatchingGroup(c12624008.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将检索到的所有符合条件的怪兽以效果破坏送去墓地。
	Duel.Destroy(g,REASON_EFFECT)
end
