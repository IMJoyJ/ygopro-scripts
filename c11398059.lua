--キングレムリン
-- 效果：
-- 4星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从卡组把1只爬虫类族怪兽加入手卡。
function c11398059.initial_effect(c)
	-- 为这张卡添加超量召唤手续：以2只4星怪兽作为超量素材进行超量召唤。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从卡组把1只爬虫类族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11398059,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c11398059.cost)
	e1:SetTarget(c11398059.target)
	e1:SetOperation(c11398059.operation)
	c:RegisterEffect(e1)
end
-- 支付发动所需的代价：从这张卡上取除1个超量素材。
function c11398059.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 检索过滤：筛选出卡组中种族为爬虫类族且可以被加入手卡的怪兽卡。
function c11398059.filter(c)
	return c:IsRace(RACE_REPTILE) and c:IsAbleToHand()
end
-- 发动条件与操作信息：确认卡组存在符合条件的爬虫类族怪兽，并登记本次效果将把1张卡从卡组加入手卡。
function c11398059.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：若卡组中不存在任何1张爬虫类族且能加入手卡的怪兽，则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c11398059.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记效果处理信息：告知系统本次效果涉及从卡组将卡加入手卡，供连锁与时点判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组挑选1只爬虫类族怪兽加入手卡，并向对方展示该卡。
function c11398059.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示玩家选择要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中筛选并选择1张符合条件的爬虫类族怪兽。
	local g=Duel.SelectMatchingCard(tp,c11398059.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入持有者的手卡（以效果原因）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示被加入手卡的卡，以确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
