--連続魔法
-- 效果：
-- 自己发动通常魔法时才能发动。手卡全部丢弃去墓地。这张卡的效果，变成和那张通常魔法的效果相同。
function c49398568.initial_effect(c)
	-- 自己发动通常魔法时才能发动。手卡全部丢弃去墓地。这张卡的效果，变成和那张通常魔法的效果相同。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c49398568.condition)
	e1:SetCost(c49398568.cost)
	e1:SetTarget(c49398568.target)
	e1:SetOperation(c49398568.activate)
	c:RegisterEffect(e1)
end
-- 检查本次连锁中的效果是否为“通常魔法的发动”，且该发动者为自身，以此满足“自己发动通常魔法时才能发动”的发动条件。
function c49398568.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:GetActiveType()==TYPE_SPELL and re:IsHasType(EFFECT_TYPE_ACTIVATE) and rp==tp
end
-- 手卡过滤函数：判断一张手卡是否能够作为代价被丢弃并送去墓地。
function c49398568.cfilter(c)
	return c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 代价处理：取得我方手卡组并移除连续魔法自身（已不在手卡），确认手卡数量大于0且全部满足丢弃条件后，将全部手卡丢弃去墓地。
function c49398568.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取我方的全部手卡作为代价候选。
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	hg:RemoveCard(e:GetHandler())
	if chk==0 then return hg:GetCount()>0 and hg:FilterCount(c49398568.cfilter,nil)==hg:GetCount() end
	-- 将全部手卡以“代价+丢弃”的理由送去墓地。
	Duel.SendtoGrave(hg,REASON_COST+REASON_DISCARD)
end
-- 复制目标处理：获取被连锁的通常魔法的Target函数并执行；若被复制效果为取对象效果，则为本效果也加上取对象标志，使本效果正确进行对象选择与合法性判定。
function c49398568.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ftg=re:GetTarget()
	if chkc then return ftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
	if chk==0 then
		e:SetCostCheck(false)
		return not ftg or ftg(e,tp,eg,ep,ev,re,r,rp,chk)
	end
	if re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	end
	if ftg then
		e:SetCostCheck(false)
		ftg(e,tp,eg,ep,ev,re,r,rp,chk)
	end
	-- 清除复制的效果的操作信息，使该复制效果不会被视为独立发动而被额外响应。
	Duel.ClearOperationInfo(0)
end
-- 效果结算：取出被连锁的通常魔法的Operation函数并执行，使本效果实际上变成与那张通常魔法相同的效果。
function c49398568.activate(e,tp,eg,ep,ev,re,r,rp)
	local fop=re:GetOperation()
	fop(e,tp,eg,ep,ev,re,r,rp)
end
