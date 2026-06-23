--キングレムリン
-- 效果：
-- 4星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从卡组把1只爬虫类族怪兽加入手卡。
function c11398059.initial_effect(c)
	-- 为卡片添加等级为4、需要2只怪兽进行叠放的XYZ召唤手续
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
-- 效果发动时的费用处理函数，检查是否能移除1个超量素材作为费用
function c11398059.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数，用于筛选爬虫类族且能加入手牌的怪兽
function c11398059.filter(c)
	return c:IsRace(RACE_REPTILE) and c:IsAbleToHand()
end
-- 效果发动时的目标选择函数，检查卡组中是否存在满足条件的怪兽
function c11398059.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，检查卡组中是否存在至少1张符合条件的爬虫类族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c11398059.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息，指定效果将从卡组检索1张爬虫类族怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理函数，执行检索并加入手牌的操作
function c11398059.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组中选择1张满足条件的爬虫类族怪兽
	local g=Duel.SelectMatchingCard(tp,c11398059.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽以效果原因送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认被送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
