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
-- 效果发动时的判定与操作信息设定：若场上存在至少1只怪兽，则将场上所有怪兽登记为本次效果破坏的对象（不取对象）。
function c53582587.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：在发动时（chk==0）确认场上怪兽区域是否存在至少1只怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取当前场上所有怪兽（双方怪兽区域的怪兽）作为待破坏对象的集合g。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将本次连锁的操作信息登记为破坏效果：对象为集合g，数量为g的怪兽数，用于后续效果（如星尘龙等）的发动判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时：重新获取场上当前所有怪兽；若存在怪兽，则以该效果将它们全部破坏。
function c53582587.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时获取当前场上所有怪兽的集合g，作为实际破坏的对象。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 以卡片效果（REASON_EFFECT）将集合g中的全部怪兽破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
