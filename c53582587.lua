--激流葬
-- 效果：
-- ①：怪兽召唤·反转召唤·特殊召唤时才能发动。场上的怪兽全部破坏。
function c53582587.initial_effect(c)
	-- ①：怪兽召唤·反转召唤·特殊召唤时才能发动。场上的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c53582587.target)
	e1:SetOperation(c53582587.activate)
	c:RegisterEffect(e1)
	-- ①：怪兽召唤·反转召唤·特殊召唤时才能发动。场上的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e2:SetTarget(c53582587.target)
	e2:SetOperation(c53582587.activate)
	c:RegisterEffect(e2)
	-- ①：怪兽召唤·反转召唤·特殊召唤时才能发动。场上的怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(c53582587.target)
	e3:SetOperation(c53582587.activate)
	c:RegisterEffect(e3)
end
-- 检查是否场上有怪兽，用于判断效果是否可以发动
function c53582587.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有怪兽组成group
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁操作信息，指定将要破坏场上所有怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果发动时执行的处理函数，用于破坏场上所有怪兽
function c53582587.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有怪兽组成group
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将场上所有怪兽破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
