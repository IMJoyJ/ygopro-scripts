--サイレントアビス
-- 效果：
-- 这张卡被战斗破坏送去墓地时，场上表侧表示存在的水属性怪兽以外的怪兽全部破坏。
function c86442081.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，场上表侧表示存在的水属性怪兽以外的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86442081,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c86442081.condition)
	e1:SetTarget(c86442081.target)
	e1:SetOperation(c86442081.operation)
	c:RegisterEffect(e1)
end
-- 确认这张卡是否是被战斗破坏并送去墓地
function c86442081.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤出里侧表示的怪兽以及非水属性的怪兽（即表侧表示水属性怪兽以外的怪兽）
function c86442081.filter(c)
	return (c:IsFacedown() or c:GetAttribute()~=ATTRIBUTE_WATER)
end
-- 效果发动的目标，收集场上所有符合条件的怪兽并设置破坏的操作信息
function c86442081.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上所有里侧表示以及非水属性的怪兽
	local g=Duel.GetMatchingGroup(c86442081.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置破坏的操作信息，指定要破坏的卡片组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理，获取当前场上符合条件的怪兽并将其全部破坏
function c86442081.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前双方场上所有里侧表示以及非水属性的怪兽
	local g=Duel.GetMatchingGroup(c86442081.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 因效果破坏指定的怪兽组
	Duel.Destroy(g,REASON_EFFECT)
end
