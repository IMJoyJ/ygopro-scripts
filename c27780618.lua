--V・HERO ヴァイオン
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只「英雄」怪兽送去墓地。
-- ②：1回合1次，从自己墓地把1只「英雄」怪兽除外才能发动。从卡组把1张「融合」加入手卡。
function c27780618.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只「英雄」怪兽送去墓地。
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
-- 过滤函数，用于筛选满足条件的「英雄」怪兽（怪兽卡且能送去墓地）
function c27780618.tgfilter(c)
	return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果发动时的处理函数，检查是否满足发动条件并设置操作信息
function c27780618.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以玩家tp来看的卡组中是否存在至少1张满足tgfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c27780618.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将要处理1张送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行将卡送去墓地的操作
function c27780618.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c27780618.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤函数，用于筛选满足条件的「英雄」怪兽（怪兽卡且能除外）
function c27780618.thcfilter(c)
	return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果发动时的处理函数，检查是否满足发动条件并设置操作信息
function c27780618.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以玩家tp来看的墓地中是否存在至少1张满足thcfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c27780618.thcfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c27780618.thcfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数，用于筛选满足条件的「融合」魔法卡（能加入手牌）
function c27780618.thfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 效果发动时的处理函数，检查是否满足发动条件并设置操作信息
function c27780618.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以玩家tp来看的卡组中是否存在至少1张满足thfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c27780618.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将要处理1张加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行将卡加入手牌的操作
function c27780618.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c27780618.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
