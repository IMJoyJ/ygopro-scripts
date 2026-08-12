--大落とし穴
-- 效果：
-- 同时有2只以上的怪兽特殊召唤成功时才能发动。场上存在的怪兽全部破坏。
function c80723580.initial_effect(c)
	-- 同时有2只以上的怪兽特殊召唤成功时才能发动。场上存在的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c80723580.condition)
	e1:SetTarget(c80723580.target)
	e1:SetOperation(c80723580.activate)
	c:RegisterEffect(e1)
end
-- 检查同时特殊召唤的怪兽数量是否在2只以上
function c80723580.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetCount()>=2
end
-- 效果发动的靶向处理，检查场上是否存在怪兽，并向系统宣告将要破坏场上的所有怪兽
function c80723580.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有的怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁的操作信息，向系统宣告此效果的处理为破坏场上的所有怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理，获取场上的所有怪兽并将其全部破坏
function c80723580.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上所有的怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 因效果破坏获取到的所有怪兽
		Duel.Destroy(g,REASON_EFFECT)
	end
end
