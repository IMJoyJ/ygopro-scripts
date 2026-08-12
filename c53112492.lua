--対抗魔術
-- 效果：
-- 把自己场上存在的2个魔力指示物取除发动。魔法卡的发动无效并破坏。
function c53112492.initial_effect(c)
	-- 把自己场上存在的2个魔力指示物取除发动。魔法卡的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c53112492.condition)
	e1:SetCost(c53112492.cost)
	e1:SetTarget(c53112492.target)
	e1:SetOperation(c53112492.activate)
	c:RegisterEffect(e1)
end
c53112492.mentioned_counter={
	[0x1]=true,
}
-- 发动条件：连锁中的效果必须是魔法卡的发动且该发动可以被无效
function c53112492.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查连锁中的效果是魔法卡的发动（效果类型为魔法且为卡的发动），且该连锁的发动可以被无效
	return re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 发动代价：取除自己场上2个魔力指示物
function c53112492.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可以取除的2个魔力指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,2,REASON_COST) end
	-- 把自己场上存在的2个魔力指示物取除
	Duel.RemoveCounter(tp,1,0,0x1,2,REASON_COST)
end
-- 发动时设定操作信息：确定要无效该连锁的魔法卡发动，若那张卡还能被破坏则同时设定破坏信息
function c53112492.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定操作信息：本连锁处理时将把作为连锁对象的魔法卡的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若发动效果的魔法卡仍可被破坏且与该效果保持联系，设定操作信息：处理时将其破坏
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使该连锁的魔法卡发动无效，若无效成功且那张卡仍与效果保持联系则将其破坏
function c53112492.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁中的魔法卡的发动无效，并确认发动该效果的卡仍与效果保持联系（在场上）
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 魔法卡的发动无效并破坏：以效果原因将作为连锁对象的那张魔法卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
