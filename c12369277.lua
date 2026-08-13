--超量士ブルーレイヤー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤时才能发动。从卡组把「超级量子战士 蓝光层」以外的1张「超级量子」卡加入手卡。
-- ②：这张卡被送去墓地的场合，以自己墓地最多3张「超级量子」卡为对象才能发动。那些卡回到卡组。
function c12369277.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·特殊召唤时才能发动。从卡组把「超级量子战士 蓝光层」以外的1张「超级量子」卡加入手卡。
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
-- 检索过滤条件：满足「超级量子」字段、不是「超级量子战士 蓝光层」自身、并且可以加入手卡的卡。
function c12369277.thfilter(c)
	return c:IsSetCard(0xdc) and not c:IsCode(12369277) and c:IsAbleToHand()
end
-- ①效果的目标与发动条件设定：检查卡组是否存在可检索的卡，并将本次连锁的操作信息标记为从卡组检索1张卡加入手卡。
function c12369277.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性判定：若处于发动前检查阶段（chk==0），则确认卡组中是否存在至少1张满足thfilter条件的卡，存在才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c12369277.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设定操作信息：将本连锁的效果分类登记为加入手卡+检索，预计从玩家tp的卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：提示玩家选择要加入手卡的卡，从卡组选出1张满足条件的卡；若有则加入持有者手卡，并向对方确认检索到的卡。
function c12369277.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要加入手牌的卡”的选择提示，用于检索卡的选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从玩家tp的卡组中选择1张满足thfilter条件的卡，筛选范围为玩家tp自己的卡组。
	local g=Duel.SelectMatchingCard(tp,c12369277.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 以效果原因（REASON_EFFECT）将选中的卡加入其持有者的手卡（player为nil时返回持有者手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的检索结果展示给对方玩家确认，保证检索信息透明。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 回卡组过滤条件：满足「超级量子」字段并且可以返回卡组的卡。
function c12369277.tdfilter(c)
	return c:IsSetCard(0xdc) and c:IsAbleToDeck()
end
-- ②效果的目标与发动条件设定：检查自己墓地存在可返回卡组的「超级量子」卡，然后选择1~3张作为对象，并设定回卡组的操作信息。
function c12369277.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c12369277.tdfilter(chkc) end
	-- 发动时合法性判定：若处于发动前检查阶段（chk==0），则确认自己墓地是否存在至少1张满足tdfilter且能成为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(c12369277.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示“请选择要返回卡组的卡”的选择提示，用于对象选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地选择1~3张满足tdfilter的「超级量子」卡，并通过Duel.SelectTarget将它们登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c12369277.tdfilter,tp,LOCATION_GRAVE,0,1,3,nil)
	-- 设定操作信息：将本连锁的效果分类登记为回卡组，对象为选中的g，数量为g的数量，目标玩家和位置参数为0。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- ②效果处理：从连锁信息中取出对象卡，并过滤出仍与该效果相关的卡，随后将它们以效果原因送回持有者卡组并洗牌。
function c12369277.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁的对象卡组，并用Card.IsRelateToEffect过滤掉已经离场或失去关联的卡，只保留仍可正常处理的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将筛选出的卡以效果原因（REASON_EFFECT）送回持有者卡组，使用SEQ_DECKSHUFFLE表示送回后需要洗牌。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
