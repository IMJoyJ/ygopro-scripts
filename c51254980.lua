--ナチュル・マンティス
-- 效果：
-- 对方对怪兽的召唤成功时，可以从手卡把1只名字带有「自然」的怪兽送去墓地，那只怪兽破坏。
function c51254980.initial_effect(c)
	-- 对方对怪兽的召唤成功时，可以从手卡把1只名字带有「自然」的怪兽送去墓地，那只怪兽破坏。
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
-- 过滤函数，用于筛选手卡中名字带有「自然」的怪兽
function c51254980.cfilter(c)
	return c:IsSetCard(0x2a) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 效果处理时的费用支付流程，选择并送入墓地一张符合条件的怪兽
function c51254980.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足费用条件，即手卡是否存在至少1张符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c51254980.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡中选择1张符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c51254980.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的怪兽送入墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果的目标设定函数，判断是否为对方召唤成功的怪兽且在主要怪兽区
function c51254980.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return ep~=tp and eg:GetFirst():IsLocation(LOCATION_MZONE) end
	eg:GetFirst():CreateEffectRelation(e)
	-- 设置连锁操作信息，确定破坏效果影响的对象数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
-- 效果的处理函数，对符合条件的怪兽进行破坏
function c51254980.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因进行破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
