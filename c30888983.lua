--方舟の選別
-- 效果：
-- ①：自己或者对方把怪兽召唤·反转召唤·特殊召唤之际支付1000基本分才能发动。场上有相同种族的怪兽存在的怪兽的召唤·反转召唤·特殊召唤无效，那些怪兽破坏。
function c30888983.initial_effect(c)
	-- ①：自己或对方把怪兽召唤·反转召唤·特殊召唤之际，支付1000基本分才能发动。和那怪兽相同种族的其他怪兽在场上存在的场合，那召唤·反转召唤·特殊召唤无效，那怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	e1:SetCondition(c30888983.condition)
	e1:SetCost(c30888983.cost)
	e1:SetTarget(c30888983.target)
	e1:SetOperation(c30888983.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e3)
end
-- 判断卡片c是否表侧表示且种族为rc，用于筛选与召唤怪兽相同种族的场上表侧表示怪兽。
function c30888983.cfilter(c,rc)
	return c:IsFaceup() and c:IsRace(rc)
end
-- 判断正在召唤的怪兽c在场上（双方主要怪兽区）是否存在至少1只表侧表示且种族与c相同的其他怪兽。
function c30888983.filter(c)
	-- 从双方场上主要怪兽区检索是否存在至少1张表侧表示且种族与召唤怪兽c相同、且不同于c的怪兽卡。
	return Duel.IsExistingMatchingCard(c30888983.cfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetRace())
end
-- 发动条件：当前没有处于连锁处理中（神宣类召唤无效时点），且本次召唤的怪兽组eg中存在至少1只满足“场上有相同种族其他怪兽”的怪兽。
function c30888983.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 满足发动条件需同时满足：无连锁处理中，且eg中存在符合条件的召唤怪兽。
	return aux.NegateSummonCondition() and eg:IsExists(c30888983.filter,1,nil)
end
-- 发动费用：支付1000基本分；chk==0时仅检查能否支付，不实际支付。
function c30888983.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家tp能否支付1000基本分（费用确认阶段）。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际支付1000基本分作为发动费用。
	Duel.PayLPCost(tp,1000)
end
-- 效果发动时选定处理对象：从本次召唤的怪兽组eg中筛出满足条件的怪兽，并设置无效召唤与破坏的操作信息。
function c30888983.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(c30888983.filter,nil)
	-- 设置操作信息：无效召唤的对象为筛选出的怪兽g，数量为g的数量，供时点/连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,g,g:GetCount(),0,0)
	-- 设置操作信息：破坏的对象为筛选出的怪兽g，数量为g的数量，供时点/连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时：重新从本次召唤的怪兽组eg中筛选出仍满足条件的怪兽，将其召唤无效并破坏。
function c30888983.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c30888983.filter,nil)
	-- 将筛选出的正在召唤的怪兽g的召唤无效。
	Duel.NegateSummon(g)
	-- 将上述召唤被无效的怪兽g破坏，破坏原因为效果。
	Duel.Destroy(g,REASON_EFFECT)
end
