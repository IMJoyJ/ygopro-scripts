--V・HERO ヴァイオン
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只「英雄」怪兽送去墓地。
-- ②：1回合1次，从自己墓地把1只「英雄」怪兽除外才能发动。从卡组把1张「融合」加入手卡。
function c27780618.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只「英雄」怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27780618,0))  --"「英雄」怪兽送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,27780618)
	e1:SetTarget(c27780618.tgtg)
	e1:SetOperation(c27780618.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：1回合1次，从自己墓地把1只「英雄」怪兽除外才能发动。从卡组把1张「融合」加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(27780618,1))  --"「融合」加入手卡"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c27780618.thcost)
	e3:SetTarget(c27780618.thtg)
	e3:SetOperation(c27780618.thop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断卡片是否为「英雄」字段的怪兽且可以送去墓地，用于①效果从卡组选送墓对象。
function c27780618.tgfilter(c)
	return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- ①效果的发动条件与操作信息设定：先检查卡组是否存在符合条件的「英雄」怪兽，再预设本次效果将把1张卡从卡组送去墓地。
function c27780618.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：在效果发动的check时确认卡组存在至少1张满足tgfilter的「英雄」怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c27780618.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：声明此效果处理时会将1张卡从卡组送去墓地，供连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果的实际处理：从卡组选择1只符合条件的「英雄」怪兽，将其送去墓地。
function c27780618.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送选择提示：提示玩家选择一张要送去墓地的卡片，并缓存选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1张满足tgfilter条件的「英雄」怪兽作为效果处理对象。
	local g=Duel.SelectMatchingCard(tp,c27780618.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择到的「英雄」怪兽以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- ②效果代价的过滤函数：判断墓地中的卡片是否为「英雄」字段的怪兽且可以作为代价除外。
function c27780618.thcfilter(c)
	return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- ②效果的发动cost：确认墓地存在可除外的「英雄」怪兽后，从自己墓地选择1只「英雄」怪兽表侧除外作为发动费用。
function c27780618.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价合法性检查：确认墓地中至少存在1张满足thcfilter的「英雄」怪兽，满足才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c27780618.thcfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 发送选择提示：提示玩家选择一张要除外的卡片并缓存选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张满足thcfilter条件的「英雄」怪兽作为除外代价。
	local g=Duel.SelectMatchingCard(tp,c27780618.thcfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的「英雄」怪兽以表侧表示除外，原因记为代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果检索目标的过滤函数：判断卡组中的卡片是否为「融合」（卡号24094653）且可以加入手卡。
function c27780618.thfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- ②效果的检索目标判定：检查卡组中是否存在「融合」并设置操作信息为从卡组加入手卡。
function c27780618.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检索合法性检查：确认卡组中存在至少1张「融合」卡，否则效果处理时无法检索。
	if chk==0 then return Duel.IsExistingMatchingCard(c27780618.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：声明此效果处理时会将1张「融合」从卡组加入手卡，供连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的实际处理：从卡组选择1张「融合」加入手卡，并向对方展示那张卡。
function c27780618.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送选择提示：提示玩家选择一张要加入手牌的卡片并缓存选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足thfilter条件的「融合」作为加入手卡的对象。
	local g=Duel.SelectMatchingCard(tp,c27780618.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择到的「融合」加入其持有者的手卡，原因记为效果（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将刚刚加入手卡的「融合」展示给对方玩家确认，保证信息透明。
		Duel.ConfirmCards(1-tp,g)
	end
end
