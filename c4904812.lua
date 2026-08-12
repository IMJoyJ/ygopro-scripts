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
-- 过滤函数，用于检查卡组中是否存在满足条件的水属性怪兽（可送入墓地作为代价）
function c4904812.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToGraveAsCost()
end
-- 效果的发动费用处理，检查是否能从卡组选择1只水属性怪兽送去墓地
function c4904812.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查在卡组中是否存在至少1张满足cfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c4904812.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1张满足条件的卡作为发动费用
	local g=Duel.SelectMatchingCard(tp,c4904812.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的卡送去墓地作为发动效果的代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤函数，用于检查卡组中是否存在「次世代控制员」（卡号68505803）
function c4904812.filter(c)
	return c:IsCode(68505803) and c:IsAbleToHand()
end
-- 设置效果的目标，确认卡组中存在「次世代控制员」并准备将其加入手牌
function c4904812.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查在卡组中是否存在至少1张「次世代控制员」
	if chk==0 then return Duel.IsExistingMatchingCard(c4904812.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将要从卡组检索1张「次世代控制员」加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理函数，执行将「次世代控制员」加入手牌的操作
function c4904812.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中检索满足条件的第一张「次世代控制员」
	local tc=Duel.GetFirstMatchingCard(c4904812.filter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 将检索到的「次世代控制员」送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认自己从卡组检索到的卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
