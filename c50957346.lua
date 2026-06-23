--レイジアース
-- 效果：
-- 这张卡被战斗破坏送去墓地时，场上表侧表示存在的地属性怪兽以外的怪兽全部破坏。
function c50957346.initial_effect(c)
	-- 诱发必发效果，对应一速的【……发动】
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
-- 这张卡被战斗破坏送去墓地时
function c50957346.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 地属性怪兽以外的怪兽
function c50957346.filter(c)
	return (c:IsFacedown() or c:GetAttribute()~=ATTRIBUTE_EARTH)
end
-- 检索满足条件的卡片组
function c50957346.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检索满足条件的卡片组
	local g=Duel.GetMatchingGroup(c50957346.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁的操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理，将目标怪兽全部破坏
function c50957346.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足条件的卡片组
	local g=Duel.GetMatchingGroup(c50957346.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 以效果为原因破坏目标怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
