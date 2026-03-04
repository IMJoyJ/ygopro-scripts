--超量士ブルーレイヤー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤时才能发动。从卡组把「超级量子战士 蓝光层」以外的1张「超级量子」卡加入手卡。
-- ②：这张卡被送去墓地的场合，以自己墓地最多3张「超级量子」卡为对象才能发动。那些卡回到卡组。
function c12369277.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤时才能发动。从卡组把「超级量子战士 蓝光层」以外的1张「超级量子」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12369277,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,12369277)
	e1:SetTarget(c12369277.thtg)
	e1:SetOperation(c12369277.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被送去墓地的场合，以自己墓地最多3张「超级量子」卡为对象才能发动。那些卡回到卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(12369277,1))  --"回到卡组"
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,12369278)
	e3:SetTarget(c12369277.tdtg)
	e3:SetOperation(c12369277.tdop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的卡片组，用于判断是否能从卡组加入手牌
function c12369277.thfilter(c)
	return c:IsSetCard(0xdc) and not c:IsCode(12369277) and c:IsAbleToHand()
end
-- 设置效果发动时的处理目标，用于判断是否满足发动条件
function c12369277.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以玩家tp来看的卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c12369277.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息，表示将要处理的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 设置效果发动时的处理操作，用于执行效果
function c12369277.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择满足条件的1张卡加入手牌
	local g=Duel.SelectMatchingCard(tp,c12369277.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方玩家看到被送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 检索满足条件的卡片组，用于判断是否能从墓地返回卡组
function c12369277.tdfilter(c)
	return c:IsSetCard(0xdc) and c:IsAbleToDeck()
end
-- 设置效果发动时的处理目标，用于判断是否满足发动条件
function c12369277.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c12369277.tdfilter(chkc) end
	-- 检查以玩家tp来看的墓地中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingTarget(c12369277.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	-- 选择满足条件的1至3张卡返回卡组
	local g=Duel.SelectTarget(tp,c12369277.tdfilter,tp,LOCATION_GRAVE,0,1,3,nil)
	-- 设置连锁处理信息，表示将要处理的卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 设置效果发动时的处理操作，用于执行效果
function c12369277.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设置的目标卡组，并筛选出与当前效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送回卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
