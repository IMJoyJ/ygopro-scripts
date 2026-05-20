--ダークネスソウル
-- 效果：
-- 这张卡被战斗破坏送去墓地时，场上表侧表示存在的暗属性怪兽以外的怪兽全部破坏。
function c86229493.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，场上表侧表示存在的暗属性怪兽以外的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86229493,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c86229493.condition)
	e1:SetTarget(c86229493.target)
	e1:SetOperation(c86229493.operation)
	c:RegisterEffect(e1)
end
-- 检查这张卡是否是被战斗破坏并送去墓地
function c86229493.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤出里侧表示的怪兽以及表侧表示的非暗属性怪兽
function c86229493.filter(c)
	return (c:IsFacedown() or c:GetAttribute()~=ATTRIBUTE_DARK)
end
-- 效果发动的目标确认，收集场上所有符合条件的怪兽并设置破坏的操作信息
function c86229493.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上所有的里侧表示怪兽以及表侧表示的非暗属性怪兽
	local g=Duel.GetMatchingGroup(c86229493.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置效果处理的操作信息，表明此效果会破坏上述符合条件的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理，获取场上符合条件的怪兽并将其全部破坏
function c86229493.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，重新获取双方场上所有的里侧表示怪兽以及表侧表示的非暗属性怪兽
	local g=Duel.GetMatchingGroup(c86229493.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将符合条件的怪兽全部因效果破坏
	Duel.Destroy(g,REASON_EFFECT)
end
