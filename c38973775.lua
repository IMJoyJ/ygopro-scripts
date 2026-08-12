--フォトン・リザード
-- 效果：
-- 把这张卡解放才能发动。从卡组把1只4星以下的名字带有「光子」的怪兽加入手卡。「光子蜥蜴」的效果1回合只能使用1次。
function c38973775.initial_effect(c)
	-- 把这张卡解放才能发动。从卡组把1只4星以下的名字带有「光子」的怪兽加入手卡。「光子蜥蜴」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38973775,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,38973775)
	e1:SetCost(c38973775.cost)
	e1:SetTarget(c38973775.target)
	e1:SetOperation(c38973775.operation)
	c:RegisterEffect(e1)
end
-- 检查是否可以解放这张卡作为发动代价
function c38973775.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡解放作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数，用于筛选4星以下、名字带有「光子」且可以加入手牌的怪兽
function c38973775.filter(c)
	return c:IsLevelBelow(4) and c:IsSetCard(0x55) and c:IsAbleToHand()
end
-- 检查是否满足发动条件并设置连锁操作信息
function c38973775.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c38973775.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将从卡组检索怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行效果处理，选择并把符合条件的怪兽加入手牌
function c38973775.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c38973775.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
