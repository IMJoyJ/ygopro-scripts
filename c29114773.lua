--SRスクラッチ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡把1张「疾行机人」卡送去墓地才能发动。从卡组把1只「疾行机人」怪兽加入手卡。
function c29114773.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从手卡把1张「疾行机人」卡送去墓地才能发动。从卡组把1只「疾行机人」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,29114773+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c29114773.cost)
	e1:SetTarget(c29114773.target)
	e1:SetOperation(c29114773.activate)
	c:RegisterEffect(e1)
end
-- 定义cost过滤器：检查卡片是否为「疾行机人」系列卡，并且可以作为代价送去墓地。
function c29114773.costfilter(c)
	return c:IsSetCard(0x2016) and c:IsAbleToGraveAsCost()
end
-- cost函数：支付发动代价，从手卡选择1张「疾行机人」卡送去墓地。
function c29114773.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在至少1张满足costfilter条件、且不是效果发动者自身的「疾行机人」卡，以判定是否可以支付代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c29114773.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 向玩家发出选择提示，要求选择1张要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从手卡选择1张满足costfilter的「疾行机人」卡（排除效果发动者自身）作为代价。
	local g=Duel.SelectMatchingCard(tp,c29114773.costfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 将选中的卡以代价（REASON_COST）送去墓地，完成cost支付。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义检索过滤器：检查卡片是否为「疾行机人」系列、怪兽卡，并且可以被加入手卡。
function c29114773.filter(c)
	return c:IsSetCard(0x2016) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- target函数：发动时确认是否存在可检索的「疾行机人」怪兽，并设置本次效果处理的操作信息为从卡组加入手卡。
function c29114773.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少1张满足filter条件的「疾行机人」怪兽，以决定效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c29114773.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果将把1张卡从卡组加入手卡（处理时再选择具体卡片）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- activate函数：效果处理时从卡组选择1只「疾行机人」怪兽加入手卡，并向对方展示。
function c29114773.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发出选择提示，要求选择1张要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1只满足filter条件的「疾行机人」怪兽。
	local g=Duel.SelectMatchingCard(tp,c29114773.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「疾行机人」怪兽加入手卡（原因：效果）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
