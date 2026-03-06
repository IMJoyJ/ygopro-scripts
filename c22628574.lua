--フェイク・フェザー
-- 效果：
-- 从手卡把1只名字带有「黑羽」的怪兽送去墓地，选择对方墓地存在的1张通常陷阱卡发动。这张卡的效果变成和选择的通常陷阱卡的效果相同。
function c22628574.initial_effect(c)
	-- 效果原文：从手卡把1只名字带有「黑羽」的怪兽送去墓地，选择对方墓地存在的1张通常陷阱卡发动。这张卡的效果变成和选择的通常陷阱卡的效果相同。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0x1e1,0x1e1)
	e1:SetCost(c22628574.cost)
	e1:SetTarget(c22628574.target)
	e1:SetOperation(c22628574.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：选择满足条件的怪兽（黑羽卡组、怪兽类型、可作为墓地代价）
function c22628574.cfilter(c)
	return c:IsSetCard(0x33) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 效果处理：检查手牌是否存在满足条件的怪兽，若有则提示选择并将其送去墓地作为代价
function c22628574.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件判断：检查手牌是否存在至少1张满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c22628574.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示信息：提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择卡片：从手牌中选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c22628574.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 操作执行：将选择的卡送去墓地作为代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤函数：选择满足条件的通常陷阱卡（类型为陷阱、非自身或特定卡、可发动效果）
function c22628574.filter(c)
	return c:GetType()==0x4 and not c:IsCode(22628574,79766336,6351147) and c:CheckActivateEffect(false,true,false)~=nil
end
-- 效果处理：检查对方墓地是否存在满足条件的通常陷阱卡，若有则选择该卡并复制其效果
function c22628574.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,1,true)
	end
	-- 条件判断：检查对方墓地是否存在至少1张满足条件的通常陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c22628574.filter,tp,0,LOCATION_GRAVE,1,nil) end
	e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 提示信息：提示玩家选择一张通常陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(22628574,0))  --"请选择一张通常陷阱"
	-- 选择卡片：从对方墓地中选择1张满足条件的通常陷阱卡
	local g=Duel.SelectTarget(tp,c22628574.filter,tp,0,LOCATION_GRAVE,1,1,nil)
	if not g then return false end
	local te,eg,ep,ev,re,r,rp=g:GetFirst():CheckActivateEffect(false,true,true)
	e:SetLabelObject(te)
	-- 清除目标：清除当前连锁中的目标卡片
	Duel.ClearTargetCard()
	local tg=te:GetTarget()
	e:SetProperty(te:GetProperty())
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	-- 清除操作信息：清除当前连锁的操作信息
	Duel.ClearOperationInfo(0)
end
-- 效果处理：复制并执行所选陷阱卡的效果
function c22628574.operation(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
