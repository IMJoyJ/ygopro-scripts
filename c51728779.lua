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
-- 过滤函数，用于判断手牌中是否包含「堕天使」卡且可被丢弃
function c51728779.cfilter(c)
	return c:IsSetCard(0xef) and c:IsDiscardable()
end
-- 检查是否满足①效果的发动条件：手牌中存在「堕天使」卡且可被丢弃
function c51728779.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable()
		-- 检查是否满足①效果的发动条件：手牌中存在「堕天使」卡且可被丢弃
		and Duel.IsExistingMatchingCard(c51728779.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择满足条件的「堕天使」卡加入丢弃组
	local g=Duel.SelectMatchingCard(tp,c51728779.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 将选中的卡送去墓地作为①效果的代价
	Duel.SendtoGrave(g,REASON_DISCARD+REASON_COST)
end
-- 过滤函数，用于判断墓地中是否包含可加入手牌的「堕天使」卡
function c51728779.thfilter(c)
	return c:IsSetCard(0xef) and c:IsAbleToHand()
end
-- 设置①效果的目标选择函数，用于选择墓地中的「堕天使」卡
function c51728779.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c51728779.thfilter(chkc) end
	-- 检查是否满足①效果的目标选择条件：墓地存在「堕天使」卡
	if chk==0 then return Duel.IsExistingTarget(c51728779.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标墓地中的「堕天使」卡
	local g=Duel.SelectTarget(tp,c51728779.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置①效果的操作信息，指定将卡送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果的处理函数，将选中的卡送入手牌
function c51728779.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ②效果的发动代价函数，检查并支付1000基本分
function c51728779.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分作为②效果的代价
	Duel.PayLPCost(tp,1000)
end
-- 过滤函数，用于判断墓地中是否存在可发动效果的「堕天使」魔法·陷阱卡
function c51728779.cpfilter(c)
	return c:IsSetCard(0xef) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck() and c:CheckActivateEffect(false,true,false)~=nil
end
-- 设置②效果的目标选择函数，用于选择墓地中的「堕天使」魔法·陷阱卡
function c51728779.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	-- 检查是否满足②效果的目标选择条件：墓地存在「堕天使」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c51728779.cpfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要发动效果的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择目标墓地中的「堕天使」魔法·陷阱卡
	local g=Duel.SelectTarget(tp,c51728779.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	-- 清除当前连锁的目标卡
	Duel.ClearTargetCard()
	g:GetFirst():CreateEffectRelation(e)
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前处理的连锁操作信息
	Duel.ClearOperationInfo(0)
	-- 设置②效果的操作信息，指定将卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ②效果的处理函数，发动选中卡的效果并将其送回卡组
function c51728779.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	if not te:GetHandler():IsRelateToEffect(e) then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
	-- 中断当前效果，使后续处理视为不同时处理
	Duel.BreakEffect()
	-- 将发动效果的卡送回卡组并洗牌
	Duel.SendtoDeck(te:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
