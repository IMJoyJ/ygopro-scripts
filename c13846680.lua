--ヘルプロミネンス
-- 效果：
-- 这张卡被战斗破坏送去墓地时，场上表侧表示存在的炎属性怪兽以外的怪兽全部破坏。
function c13846680.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，场上表侧表示存在的炎属性怪兽以外的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13846680,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c13846680.condition)
	e1:SetTarget(c13846680.target)
	e1:SetOperation(c13846680.operation)
	c:RegisterEffect(e1)
end
-- 效果触发条件：效果持有者（这张卡）位于墓地且因战斗被破坏，满足『被战斗破坏送去墓地时』的时点。
function c13846680.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 筛选条件：选择场上里侧表示或属性不是炎属性的怪兽（即炎属性怪兽以外的怪兽，包括里侧表示的怪兽）。
function c13846680.filter(c)
	return (c:IsFacedown() or c:GetAttribute()~=ATTRIBUTE_FIRE)
end
-- 发动时判定：可以发动时返回true，并获取场上符合筛选条件的全部怪兽，设置本次效果为破坏这些怪兽。
function c13846680.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方怪兽区域中所有满足筛选条件（里侧表示或非炎属性）的怪兽，作为可能被破坏的候选。
	local g=Duel.GetMatchingGroup(c13846680.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：声明本次连锁将破坏目标组g中的所有卡，数量为g中卡的数量，供其他卡牌效果参考。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：再次获取当前场上符合条件的所有怪兽并全部破坏。
function c13846680.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新筛选双方怪兽区域中满足条件（里侧表示或非炎属性）的怪兽。
	local g=Duel.GetMatchingGroup(c13846680.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 以效果原因将筛选出的怪兽全部破坏并送去墓地。
	Duel.Destroy(g,REASON_EFFECT)
end
