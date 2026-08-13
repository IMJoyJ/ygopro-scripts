--ハーピィの羽根帚
-- 效果：
-- ①：对方场上的魔法·陷阱卡全部破坏。
function c18144506.initial_effect(c)
	-- ①：对方场上的魔法·陷阱卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c18144506.target)
	e1:SetOperation(c18144506.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选函数：仅选择魔法·陷阱卡，用于筛出对方场上可被破坏的魔法·陷阱卡。
function c18144506.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动时的目标处理函数：先检查能否发动，再获取对方场上全部魔法·陷阱卡并登记破坏信息。
function c18144506.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 若在发动时（chk==0），检查对方场上是否存在至少1张除发动中的这张卡以外的魔法·陷阱卡，不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c18144506.filter,tp,0,LOCATION_ONFIELD,1,c) end
	-- 获取对方场上所有魔法·陷阱卡（排除发动中的这张卡），作为本次将被破坏的候选对象组。
	local sg=Duel.GetMatchingGroup(c18144506.filter,tp,0,LOCATION_ONFIELD,c)
	-- 登记操作信息：将sg全部卡片预定为被破坏对象，数量为sg:GetCount()，供连锁检测和相关效果使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果处理函数：在效果结算时实际执行破坏操作。
function c18144506.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时重新获取对方场上所有魔法·陷阱卡（排除发动中的这张卡），以应对处理时场上的变化。
	local sg=Duel.GetMatchingGroup(c18144506.filter,tp,0,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 将选中的卡全部破坏，破坏原因记为效果，完成“对方场上的魔法·陷阱卡全部破坏”。
	Duel.Destroy(sg,REASON_EFFECT)
end
