--極星の輝き
-- 效果：
-- 场上名字带有「极星」的怪兽不会被战斗破坏。场上的这张卡被破坏时，场上表侧表示存在的名字带有「极星」的怪兽全部破坏。
function c50433147.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：场上名字带有「极星」的怪兽不会被战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c50433147.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 效果原文内容：场上的这张卡被破坏时，场上表侧表示存在的名字带有「极星」的怪兽全部破坏
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
-- 规则层面作用：判断目标怪兽是否为名字带有「极星」的怪兽
function c50433147.indtg(e,c)
	return c:IsSetCard(0x42)
end
-- 规则层面作用：判断此卡是否从场上被破坏
function c50433147.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 规则层面作用：过滤出场上的表侧表示且名字带有「极星」的怪兽
function c50433147.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x42)
end
-- 规则层面作用：设置连锁处理时的破坏对象为所有满足条件的怪兽
function c50433147.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面作用：检索满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c50433147.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 规则层面作用：设置当前连锁的操作信息，包含要破坏的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 规则层面作用：执行对满足条件的怪兽进行破坏的效果
function c50433147.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：检索满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c50433147.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 规则层面作用：将目标怪兽以效果原因进行破坏
	Duel.Destroy(g,REASON_EFFECT)
end
