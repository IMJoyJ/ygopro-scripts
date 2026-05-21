--惑星探査車
-- 效果：
-- ①：把这张卡解放才能发动。从卡组把1张场地魔法卡加入手卡。
function c97526666.initial_effect(c)
	-- ①：把这张卡解放才能发动。从卡组把1张场地魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97526666,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c97526666.cost)
	e1:SetTarget(c97526666.target)
	e1:SetOperation(c97526666.operation)
	c:RegisterEffect(e1)
end
-- 定义发动代价：检查自身是否可以解放，并在发动时将自身解放
function c97526666.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：卡组中可以加入手牌的场地魔法卡
function c97526666.filter(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- 定义效果的目标：检查卡组中是否存在可检索的卡，并设置将卡片加入手牌的操作信息
function c97526666.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的场地魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c97526666.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示此效果会将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义效果的处理：从卡组选择1张场地魔法卡加入手牌并给对方确认
function c97526666.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的场地魔法卡
	local g=Duel.SelectMatchingCard(tp,c97526666.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
