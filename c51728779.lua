--堕天使アムドゥシアス
-- 效果：
-- 自己对「堕天使 安度西亚斯」1回合只能有1次特殊召唤，那些①②的效果1回合各能使用1次。
-- ①：从手卡把这张卡和1张「堕天使」卡丢弃，以自己墓地1张「堕天使」卡为对象才能发动。那张卡加入手卡。
-- ②：支付1000基本分，以自己墓地1张「堕天使」魔法·陷阱卡为对象才能发动。那张魔法·陷阱卡的效果适用。那之后，墓地的那张卡回到卡组。这个效果在对方回合也能发动。
function c51728779.initial_effect(c)
	c:SetSPSummonOnce(51728779)
	-- ①：从手卡把这张卡和1张「堕天使」卡丢弃，以自己墓地1张「堕天使」卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51728779,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,51728779)
	e1:SetCost(c51728779.thcost)
	e1:SetTarget(c51728779.thtg)
	e1:SetOperation(c51728779.thop)
	c:RegisterEffect(e1)
	-- ②：支付1000基本分，以自己墓地1张「堕天使」魔法·陷阱卡为对象才能发动。那张魔法·陷阱卡的效果适用。那之后，墓地的那张卡回到卡组。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51728779,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,51728780)
	e2:SetCost(c51728779.cpcost)
	e2:SetTarget(c51728779.cptg)
	e2:SetOperation(c51728779.cpop)
	c:RegisterEffect(e2)
end
-- 定义①丢弃cost的过滤器：手牌中满足「堕天使」字段且可以丢弃的卡。
function c51728779.cfilter(c)
	return c:IsSetCard(0xef) and c:IsDiscardable()
end
-- ①的cost检查：确认这张卡自身可以丢弃，并且手牌中存在其他「堕天使」卡可供丢弃。
function c51728779.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable()
		-- 检查手牌中是否存在至少1张除自身以外的可丢弃「堕天使」卡，作为①的发动条件。
		and Duel.IsExistingMatchingCard(c51728779.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 向玩家显示“请选择要丢弃的手牌”的提示，用于选择丢弃cost的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 从手牌选择1张「堕天使」卡（不包括这张卡自身），作为①的丢弃cost。
	local g=Duel.SelectMatchingCard(tp,c51728779.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 将选中的手牌和这张卡自身以丢弃·代价（REASON_DISCARD+REASON_COST）送入墓地。
	Duel.SendtoGrave(g,REASON_DISCARD+REASON_COST)
end
-- 定义①回手牌对象的过滤器：自己墓地中满足「堕天使」字段且可以加入手牌的卡。
function c51728779.thfilter(c)
	return c:IsSetCard(0xef) and c:IsAbleToHand()
end
-- ①的发动目标处理：从自己墓地选择1张「堕天使」卡作为对象，并设置回手牌的操作信息。
function c51728779.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c51728779.thfilter(chkc) end
	-- 检查自己墓地是否存在至少1张符合条件的「堕天使」卡可以作为①的对象。
	if chk==0 then return Duel.IsExistingTarget(c51728779.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示“请选择要加入手牌的卡”的提示，用于选择①的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1张「堕天使」卡，并将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c51728779.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁的操作信息：本次效果将把对象卡加入手牌（CATEGORY_TOHAND），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①的效果处理：将作为对象的墓地「堕天使」卡加入其持有者的手牌。
function c51728779.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将效果对象卡送去其持有者的手卡（REASON_EFFECT）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ②的cost处理：支付1000基本分作为发动代价。
function c51728779.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000LP作为②的发动cost。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际支付1000LP。
	Duel.PayLPCost(tp,1000)
end
-- 定义②可复制对象的过滤器：自己墓地中满足「堕天使」字段、是魔法·陷阱卡、可以回卡组且拥有可发动效果的卡。
function c51728779.cpfilter(c)
	return c:IsSetCard(0xef) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck() and c:CheckActivateEffect(false,true,false)~=nil
end
-- ②的发动目标处理：选择墓地1张「堕天使」魔法·陷阱卡，复制其效果参数并将该卡登记为对象，同时设置回卡组的操作信息。
function c51728779.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	-- 检查自己墓地是否存在至少1张符合条件的「堕天使」魔法·陷阱卡可以作为②的对象。
	if chk==0 then return Duel.IsExistingTarget(c51728779.cpfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示“请选择效果的对象”的提示，用于选择②的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从自己墓地选择1张「堕天使」魔法·陷阱卡，并暂时登记为效果对象。
	local g=Duel.SelectTarget(tp,c51728779.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	-- 清除自动登记的目标，因为后续需要用复制效果的目标逻辑重新建立关联。
	Duel.ClearTargetCard()
	g:GetFirst():CreateEffectRelation(e)
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除连锁0的操作信息，避免复制出的魔法·陷阱卡效果被错误响应或干扰。
	Duel.ClearOperationInfo(0)
	-- 设置连锁的操作信息：本次效果最终会将对象卡送回卡组（CATEGORY_TODECK），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ②的效果处理：适用被选择的魔法·陷阱卡的效果，然后将被复制的那张卡洗回持有者卡组。
function c51728779.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	if not te:GetHandler():IsRelateToEffect(e) then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
	-- 中断当前效果链，使后续回卡组的处理与复制效果的处理视为不同时处理，避免错误时点。
	Duel.BreakEffect()
	-- 将用于复制的墓地魔法·陷阱卡以效果原因洗回持有者的卡组（弹回卡组并洗切）。
	Duel.SendtoDeck(te:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
