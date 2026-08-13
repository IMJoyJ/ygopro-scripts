--ナチュル・マンティス
-- 效果：
-- 对方对怪兽的召唤成功时，可以从手卡把1只名字带有「自然」的怪兽送去墓地，那只怪兽破坏。
function c51254980.initial_effect(c)
	-- 对应整体效果原文：“对方对怪兽的召唤成功时，可以从手卡把1只名字带有「自然」的怪兽送去墓地，那只怪兽破坏。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51254980,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCost(c51254980.cost)
	e1:SetTarget(c51254980.target)
	e1:SetOperation(c51254980.operation)
	c:RegisterEffect(e1)
end
-- 代价过滤函数：检查手卡中的怪兽是否为名字带有「自然」的怪兽卡，且能否作为代价送去墓地。
function c51254980.cfilter(c)
	return c:IsSetCard(0x2a) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 代价函数：效果发动时需从手卡选1只名字带有「自然」的怪兽送去墓地作为代价；先检查是否有可选的代价，再让玩家选择并送入墓地。
function c51254980.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点检查：确认手卡中是否存在至少1张满足条件（名字带有「自然」且可作为代价送去墓地）的怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c51254980.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向操作玩家发送选择提示，提示信息为“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡中选择1张满足条件（名字带有「自然」且可作为代价送去墓地）的怪兽。
	local g=Duel.SelectMatchingCard(tp,c51254980.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的怪兽作为代价送去墓地，完成代价支付。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果目标与发动条件处理：确认召唤成功的是对方怪兽且该怪兽位于主要怪兽区；为这只召唤成功的怪兽建立与效果的联系，并设置后续将破坏该怪兽的操作信息。
function c51254980.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return ep~=tp and eg:GetFirst():IsLocation(LOCATION_MZONE) end
	eg:GetFirst():CreateEffectRelation(e)
	-- 将本次连锁的处理信息设置为破坏效果，破坏对象是这次召唤成功的怪兽，数量为1，用于后续破坏相关判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
-- 效果处理函数：从召唤成功的那组怪兽中取出对象，若该怪兽仍与此效果保持联系，则将其破坏。
function c51254980.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该怪兽，使其被效果送入墓地。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
