--竜の渓谷
-- 效果：
-- ①：1回合1次，可以丢弃1张手卡，从以下效果选择1个发动。
-- ●从卡组把1只4星以下的「龙骑兵团」怪兽加入手卡。
-- ●从卡组把1只龙族怪兽送去墓地。
function c62265044.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，可以丢弃1张手卡，从以下效果选择1个发动。●从卡组把1只4星以下的「龙骑兵团」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetDescription(aux.Stringid(62265044,1))  --"「龙骑兵团」怪兽加入手卡"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCost(c62265044.cost)
	e2:SetTarget(c62265044.target1)
	e2:SetOperation(c62265044.operation1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetDescription(aux.Stringid(62265044,2))  --"龙族怪兽送去墓地"
	e3:SetTarget(c62265044.target2)
	e3:SetOperation(c62265044.operation2)
	c:RegisterEffect(e3)
end
-- 效果发动代价（丢弃1张手卡）的处理函数
function c62265044.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查手卡中是否存在可丢弃的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 向对方玩家提示当前选择发动的效果分支
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 玩家选择并丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：4星以下的「龙骑兵团」怪兽
function c62265044.filter1(c)
	return c:IsLevelBelow(4) and c:IsSetCard(0x29) and c:IsAbleToHand()
end
-- 过滤条件：龙族怪兽
function c62265044.filter2(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToGrave()
end
-- 效果1（检索「龙骑兵团」）的发动准备与合法性检查函数
function c62265044.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查卡组中是否存在满足条件的「龙骑兵团」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c62265044.filter1,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果2（龙族送墓）的发动准备与合法性检查函数
function c62265044.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查卡组中是否存在满足条件的龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c62265044.filter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果1（检索「龙骑兵团」）的效果处理函数
function c62265044.operation1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张满足条件的「龙骑兵团」怪兽
	local g=Duel.SelectMatchingCard(tp,c62265044.filter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果2（龙族送墓）的效果处理函数
function c62265044.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从卡组选择1张满足条件的龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c62265044.filter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
