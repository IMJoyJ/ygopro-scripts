--シャドール・ヘッジホッグ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡反转的场合才能发动。从卡组把1张「影依」魔法·陷阱卡加入手卡。
-- ②：这张卡被效果送去墓地的场合才能发动。从卡组把「影依刺猬」以外的1只「影依」怪兽加入手卡。
function c4939890.initial_effect(c)
	-- ①：这张卡反转的场合才能发动。从卡组把1张「影依」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4939890,0))  --"检索魔陷"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,4939890)
	e1:SetCost(c4939890.cost)
	e1:SetTarget(c4939890.target)
	e1:SetOperation(c4939890.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合才能发动。从卡组把「影依刺猬」以外的1只「影依」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4939890,1))  --"检索怪兽"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,4939890)
	e2:SetCondition(c4939890.thcon)
	e2:SetCost(c4939890.cost)
	e2:SetTarget(c4939890.thtg)
	e2:SetOperation(c4939890.thop)
	c:RegisterEffect(e2)
	c4939890.shadoll_flip_effect=e1
end
-- 效果处理时的费用支付函数，向对方玩家提示本效果已被发动
function c4939890.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示“对方选择了：...”当前效果描述内容
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 过滤函数，用于筛选满足条件的「影依」魔法·陷阱卡
function c4939890.filter(c)
	return c:IsSetCard(0x9d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果处理时的目标选择函数，检查是否满足检索条件并设置操作信息
function c4939890.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c4939890.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将要从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的操作函数，提示玩家选择并执行检索魔法·陷阱卡
function c4939890.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c4939890.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认所选卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断此卡是否因效果而进入墓地
function c4939890.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤函数，用于筛选满足条件的「影依」怪兽（非影依刺猬）
function c4939890.thfilter(c)
	return c:IsSetCard(0x9d) and c:IsType(TYPE_MONSTER) and not c:IsCode(4939890) and c:IsAbleToHand()
end
-- 效果处理时的目标选择函数，检查是否满足检索条件并设置操作信息
function c4939890.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c4939890.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将要从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的操作函数，提示玩家选择并执行检索怪兽
function c4939890.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c4939890.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认所选卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
