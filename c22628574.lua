--フェイク・フェザー
-- 效果：
-- 从手卡把1只名字带有「黑羽」的怪兽送去墓地，选择对方墓地存在的1张通常陷阱卡发动。这张卡的效果变成和选择的通常陷阱卡的效果相同。
function c22628574.initial_effect(c)
	-- 从手卡把1只名字带有「黑羽」的怪兽送去墓地，选择对方墓地存在的1张通常陷阱卡发动。这张卡的效果变成和选择的通常陷阱卡的效果相同。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0x1e1,0x1e1)
	e1:SetCost(c22628574.cost)
	e1:SetTarget(c22628574.target)
	e1:SetOperation(c22628574.operation)
	c:RegisterEffect(e1)
end
-- 定义代价滤条件：手卡中存在名字带有「黑羽」的怪兽，可以作为代价送去墓地。
function c22628574.cfilter(c)
	return c:IsSetCard(0x33) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 发动代价的支付处理：从手卡选择1只名字带有「黑羽」的怪兽送去墓地。
function c22628574.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认手卡中是否有1只可送去墓地的「黑羽」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c22628574.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 弹出选择提示，要求玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从手卡选择1只满足条件的「黑羽」怪兽。
	local g=Duel.SelectMatchingCard(tp,c22628574.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将所选黑羽怪兽送去墓地，作为发动代价。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义可选择对象的过滤条件：对方墓地1张效果可复制的通常陷阱卡，且不能是「伪羽」「事务回滚」「黑暗中的陷阱」。
function c22628574.filter(c)
	return c:GetType()==0x4 and not c:IsCode(22628574,79766336,6351147) and c:CheckActivateEffect(false,true,false)~=nil
end
-- 发动时选择对方墓地1张通常陷阱卡，并复制其效果；若处理中需要判定对象是否合法，则沿用被复制效果的target。
function c22628574.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,1,true)
	end
	-- 发动条件检测：确认对方墓地存在1张满足条件的通常陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c22628574.filter,tp,0,LOCATION_GRAVE,1,nil) end
	e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 弹出选择提示，要求玩家选择一张通常陷阱卡。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(22628574,0))  --"请选择一张通常陷阱"
	-- 选择对方墓地1张符合条件的通常陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,c22628574.filter,tp,0,LOCATION_GRAVE,1,1,nil)
	if not g then return false end
	local te,eg,ep,ev,re,r,rp=g:GetFirst():CheckActivateEffect(false,true,true)
	e:SetLabelObject(te)
	-- 清除当前连锁的对象信息，避免后续复制效果时残留原对象。
	Duel.ClearTargetCard()
	local tg=te:GetTarget()
	e:SetProperty(te:GetProperty())
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	-- 清除当前连锁的操作信息，防止被复制效果的操作信息被错误响应。
	Duel.ClearOperationInfo(0)
end
-- 效果处理时，取得被选择的通常陷阱卡的效果操作函数并执行，即让本卡效果变成那张通常陷阱卡的效果。
function c22628574.operation(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
