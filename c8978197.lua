--ロード・オブ・ドラゴン－ドラゴンの統制者－
-- 效果：
-- ①：这张卡只要在怪兽区域存在，卡名当作「龙之支配者」使用。
-- ②：这张卡召唤成功时，从手卡丢弃1张魔法·陷阱卡才能发动。从卡组把「呼龙笛」「龙觉醒旋律」「龙复活狂奏」的其中1张加入手卡。
function c8978197.initial_effect(c)
	-- 注册卡名变更效果，使这张卡在怪兽区域存在时卡名当作「龙之支配者」使用
	aux.EnableChangeCode(c,17985575)
	-- ②：这张卡召唤成功时，从手卡丢弃1张魔法·陷阱卡才能发动。从卡组把「呼龙笛」「龙觉醒旋律」「龙复活狂奏」的其中1张加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8978197,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCost(c8978197.thcost)
	e2:SetTarget(c8978197.thtg)
	e2:SetOperation(c8978197.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手牌中的魔法·陷阱卡，且可以被丢弃
function c8978197.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsDiscardable()
end
-- 效果②的发动代价（Cost）函数：从手卡丢弃1张魔法·陷阱卡
function c8978197.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查手牌中是否存在可作为代价丢弃的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c8978197.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌中丢弃1张魔法·陷阱卡作为发动代价
	Duel.DiscardHand(tp,c8978197.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：卡组中卡名为「呼龙笛」、「龙觉醒旋律」或「龙复活狂奏」且能加入手牌的卡
function c8978197.thfilter(c)
	return c:IsCode(71867500,43973174,48800175) and c:IsAbleToHand()
end
-- 效果②的发动目标（Target）函数：检查卡组中是否存在可检索的卡，并设置操作信息
function c8978197.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查卡组中是否存在可检索的目标卡
	if chk==0 then return Duel.IsExistingMatchingCard(c8978197.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示该效果的处理为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理（Operation）函数：从卡组将1张目标卡加入手牌
function c8978197.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的目标卡
	local g=Duel.SelectMatchingCard(tp,c8978197.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
