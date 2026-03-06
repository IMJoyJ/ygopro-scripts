--SRスクラッチ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡把1张「疾行机人」卡送去墓地才能发动。从卡组把1只「疾行机人」怪兽加入手卡。
function c29114773.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
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
-- 效果作用：定义cost过滤函数，检查手卡中是否含有「疾行机人」卡且能作为cost送去墓地
function c29114773.costfilter(c)
	return c:IsSetCard(0x2016) and c:IsAbleToGraveAsCost()
end
-- 效果作用：处理发动时的cost，选择1张手卡中的「疾行机人」卡送去墓地
function c29114773.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否满足cost条件，检查手卡中是否存在至少1张「疾行机人」怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(c29114773.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 效果作用：提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 效果作用：从手卡中选择1张「疾行机人」卡作为cost
	local g=Duel.SelectMatchingCard(tp,c29114773.costfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 效果作用：将选中的卡送去墓地作为发动cost
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果原文内容：①：从手卡把1张「疾行机人」卡送去墓地才能发动。从卡组把1只「疾行机人」怪兽加入手卡。
function c29114773.filter(c)
	return c:IsSetCard(0x2016) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果作用：定义target过滤函数，检查卡组中是否存在「疾行机人」怪兽卡
function c29114773.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否满足发动条件，检查卡组中是否存在至少1张「疾行机人」怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(c29114773.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 效果作用：设置连锁操作信息，表示将从卡组检索1只「疾行机人」怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：处理效果发动时的检索和加入手牌操作
function c29114773.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 效果作用：从卡组中选择1只「疾行机人」怪兽卡
	local g=Duel.SelectMatchingCard(tp,c29114773.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 效果作用：将选中的怪兽卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 效果作用：确认对方玩家看到被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
