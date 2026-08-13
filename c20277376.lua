--神竜 アポカリプス
-- 效果：
-- 1回合1次，丢弃1张手卡才能发动。选择自己墓地1只龙族怪兽加入手卡。
function c20277376.initial_effect(c)
	-- ①：1回合1次，丢弃1张手卡，以自己墓地1只龙族怪兽为对象才能发动。那只龙族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20277376,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c20277376.thcost)
	e1:SetTarget(c20277376.thtg)
	e1:SetOperation(c20277376.thop)
	c:RegisterEffect(e1)
end
-- 代价处理函数：确认手牌有可丢弃的卡作为发动代价，并在发动时丢弃1张手卡。
function c20277376.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认自己手牌中存在至少1张可以丢弃的卡，满足代价要求。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃代价：从手牌中选1张卡丢弃，丢弃原因记为代价丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 对象筛选条件：卡片必须是龙族怪兽，并且能够加入手卡。
function c20277376.filter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
-- 目标选择处理：从自己墓地选择1只符合条件的龙族怪兽作为对象，并设定回手牌的操作信息。
function c20277376.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c20277376.filter(chkc) end
	-- 目标合法性检查：确认自己墓地存在至少1只符合条件的龙族怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c20277376.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择提示：提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只符合条件的龙族怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c20277376.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：声明该效果将把对象卡加入手牌，供后续连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数：将对象龙族怪兽加入手牌，并向对方展示。
function c20277376.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的那张对象怪兽卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_DRAGON) then
		-- 将对象卡送去其持有者的手卡，使其加入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片，以确认检索结果。
		Duel.ConfirmCards(1-tp,tc)
	end
end
