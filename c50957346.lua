--レイジアース
-- 效果：
-- 这张卡被战斗破坏送去墓地时，场上表侧表示存在的地属性怪兽以外的怪兽全部破坏。
function c50957346.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，场上表侧表示存在的地属性怪兽以外的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50957346,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c50957346.condition)
	e1:SetTarget(c50957346.target)
	e1:SetOperation(c50957346.operation)
	c:RegisterEffect(e1)
end
-- 触发条件判定：效果持有者（本卡）必须位于墓地，且是被战斗破坏送去墓地。
function c50957346.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 筛选要破坏的怪兽：里侧表示，或表侧表示但属性不是地属性的怪兽。
function c50957346.filter(c)
	return (c:IsFacedown() or c:GetAttribute()~=ATTRIBUTE_EARTH)
end
-- 效果发动时无取对象且必须发动，先确认可执行，随后获取当前场上符合筛选条件的怪兽组，并设置本次连锁涉及的破坏信息。
function c50957346.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 从双方主要怪兽区检索所有满足筛选条件的怪兽，组成不取对象的候选破坏组。
	local g=Duel.GetMatchingGroup(c50957346.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：本次效果为破坏效果，破坏对象为候选组g，数量为g中的卡数，供其他卡对此效果的应答或检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时，重新获取当前场上符合筛选条件的怪兽组，然后将这些怪兽全部破坏。
function c50957346.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次从双方主要怪兽区检索当前满足筛选条件的怪兽，作为实际要破坏的卡组。
	local g=Duel.GetMatchingGroup(c50957346.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 以效果处理原因（REASON_EFFECT）将检索到的怪兽组全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
