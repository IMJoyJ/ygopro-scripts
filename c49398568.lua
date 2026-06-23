--連続魔法
-- 效果：
-- 自己发动通常魔法时才能发动。手卡全部丢弃去墓地。这张卡的效果，变成和那张通常魔法的效果相同。
function c49398568.initial_effect(c)
	-- 创建一个效果，用于处理连续魔法的发动条件和流程
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c49398568.condition)
	e1:SetCost(c49398568.cost)
	e1:SetTarget(c49398568.target)
	e1:SetOperation(c49398568.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时，检查是否为己方发动通常魔法卡
function c49398568.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:GetActiveType()==TYPE_SPELL and re:IsHasType(EFFECT_TYPE_ACTIVATE) and rp==tp
end
-- 过滤函数，判断手牌是否可以作为丢弃和送墓的代价
function c49398568.cfilter(c)
	return c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 支付费用时，将手牌全部丢弃并送去墓地
function c49398568.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方手牌组
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	hg:RemoveCard(e:GetHandler())
	if chk==0 then return hg:GetCount()>0 and hg:FilterCount(c49398568.cfilter,nil)==hg:GetCount() end
	-- 将手牌以丢弃和费用原因送去墓地
	Duel.SendtoGrave(hg,REASON_COST+REASON_DISCARD)
end
-- 设置目标函数，用于复制原魔法卡的目标效果
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
	-- 清除当前链的OperationInfo，防止被响应
	Duel.ClearOperationInfo(0)
end
-- 发动效果时，执行原魔法卡的效果
function c49398568.activate(e,tp,eg,ep,ev,re,r,rp)
	local fop=re:GetOperation()
	fop(e,tp,eg,ep,ev,re,r,rp)
end
