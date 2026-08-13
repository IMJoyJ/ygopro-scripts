--極星の輝き
-- 效果：
-- 场上名字带有「极星」的怪兽不会被战斗破坏。场上的这张卡被破坏时，场上表侧表示存在的名字带有「极星」的怪兽全部破坏。
function c50433147.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 场上名字带有「极星」的怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c50433147.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 场上的这张卡被破坏时，场上表侧表示存在的名字带有「极星」的怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(50433147,0))  --"表侧表示的名字带有「极星」的怪兽全部破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c50433147.descon)
	e3:SetTarget(c50433147.destg)
	e3:SetOperation(c50433147.desop)
	c:RegisterEffect(e3)
end
-- 作为「不会被战斗破坏」效果的适用对象筛选：检查怪兽是否名字带有「极星」字段。
function c50433147.indtg(e,c)
	return c:IsSetCard(0x42)
end
-- 触发条件：这张卡被破坏时，且破坏前在场上区域存在时才发动。
function c50433147.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选条件：怪兽为表侧表示，且名字带有「极星」。
function c50433147.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x42)
end
-- 效果发动前的目标准备：确认可以发动后，获取当前场上所有表侧表示且名字带有「极星」的怪兽，并设置破坏这些卡的操作信息（不取对象破坏）。
function c50433147.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上主要怪兽区域中所有满足筛选条件的「极星」怪兽，作为候选破坏集合。
	local g=Duel.GetMatchingGroup(c50433147.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 登记本连锁的操作信息为破坏效果：破坏对象为g中的所有极星怪兽，数量为g的怪兽数，用于连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时，重新获取当前场上表侧表示且名字带有「极星」的怪兽，并将其全部破坏。
function c50433147.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取当前场上所有表侧表示且名字带有「极星」的怪兽集合（因为处理时场上可能已变化）。
	local g=Duel.GetMatchingGroup(c50433147.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 以效果原因将g中的所有怪兽破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
