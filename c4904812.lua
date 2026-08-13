--ジェネクス・ウンディーネ
-- 效果：
-- ①：这张卡召唤时，从卡组把1只水属性怪兽送去墓地才能发动。从卡组把1只「次世代控制员」加入手卡。
function c4904812.initial_effect(c)
	-- ①：这张卡召唤时，从卡组把1只水属性怪兽送去墓地才能发动。从卡组把1只「次世代控制员」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4904812,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCost(c4904812.cost)
	e1:SetTarget(c4904812.target)
	e1:SetOperation(c4904812.operation)
	c:RegisterEffect(e1)
end
-- 定义代价筛选函数：卡必须是水属性，且可以作为代价送去墓地。
function c4904812.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToGraveAsCost()
end
-- 代价处理：确认卡组存在水属性且可送墓的怪兽后，选择1张从卡组送去墓地作为发动代价。
function c4904812.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测（chk=0）：确认卡组中是否存在1张水属性且可作为代价送去墓地的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c4904812.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 给操作者发送选择提示，提示文字为“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1张满足cfilter条件（水属性且可送墓）的卡，作为代价送去墓地。
	local g=Duel.SelectMatchingCard(tp,c4904812.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选择的怪兽送去墓地，理由为代价（REASON_COST）。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义检索筛选函数：卡名必须是「次世代控制员」（卡号68505803），且能够加入手卡。
function c4904812.filter(c)
	return c:IsCode(68505803) and c:IsAbleToHand()
end
-- 效果发动目标的合法性检查与操作信息登记：确认卡组存在可检索的「次世代控制员」，并设定加入手卡的操作信息。
function c4904812.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检测（chk=0）：确认卡组中存在1张「次世代控制员」且能加入手卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c4904812.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本次效果将把1张卡从卡组加入手卡（属于回手牌/检索分类）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1张「次世代控制员」加入手卡，若加入成功则向对方确认那张卡。
function c4904812.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给操作者发送选择提示，提示文字为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中取得第一张满足filter条件的「次世代控制员」（通常只有一张，无需玩家选择）。
	local tc=Duel.GetFirstMatchingCard(c4904812.filter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 将检索到的「次世代控制员」加入持有者的手卡，理由为效果（REASON_EFFECT）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片（以验证检索真实性）。
		Duel.ConfirmCards(1-tp,tc)
	end
end
