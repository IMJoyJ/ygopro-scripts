--堕天使イシュタム
-- 效果：
-- 自己对「堕天使 伊希塔布」1回合只能有1次特殊召唤，那些①②的效果1回合各能使用1次。
-- ①：从手卡把这张卡和1张「堕天使」卡丢弃才能发动。自己从卡组抽2张。
-- ②：支付1000基本分，以自己墓地1张「堕天使」魔法·陷阱卡为对象才能发动。那张魔法·陷阱卡的效果适用。那之后，墓地的那张卡回到卡组。这个效果在对方回合也能发动。
function c52840267.initial_effect(c)
	c:SetSPSummonOnce(52840267)
	-- ①：从手卡把这张卡和1张「堕天使」卡丢弃才能发动。自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52840267,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,52840267)
	e1:SetCost(c52840267.drcost)
	e1:SetTarget(c52840267.drtg)
	e1:SetOperation(c52840267.drop)
	c:RegisterEffect(e1)
	-- ②：支付1000基本分，以自己墓地1张「堕天使」魔法·陷阱卡为对象才能发动。那张魔法·陷阱卡的效果适用。那之后，墓地的那张卡回到卡组。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52840267,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,52840268)
	e2:SetCost(c52840267.cpcost)
	e2:SetTarget(c52840267.cptg)
	e2:SetOperation(c52840267.cpop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手牌中是否包含「堕天使」卡且可丢弃
function c52840267.cfilter(c)
	return c:IsSetCard(0xef) and c:IsDiscardable()
end
-- 检查是否满足①效果的费用条件：手牌中有一张「堕天使」卡且自身可丢弃
function c52840267.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable()
		-- 检查是否满足①效果的费用条件：手牌中有一张「堕天使」卡且自身可丢弃
		and Duel.IsExistingMatchingCard(c52840267.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择满足条件的「堕天使」卡
	local g=Duel.SelectMatchingCard(tp,c52840267.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 将选中的卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_DISCARD+REASON_COST)
end
-- 设置①效果的目标和操作信息：抽2张卡
function c52840267.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置抽卡效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡数量为2
	Duel.SetTargetParam(2)
	-- 设置抽卡效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 执行①效果的处理：进行抽卡
function c52840267.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 设置②效果的费用条件：支付1000基本分
function c52840267.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分作为②效果的费用
	Duel.PayLPCost(tp,1000)
end
-- 过滤函数，用于判断墓地中的「堕天使」魔法·陷阱卡是否可被选中并发动其效果
function c52840267.cpfilter(c)
	return c:IsSetCard(0xef) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck() and c:CheckActivateEffect(false,true,false)~=nil
end
-- 设置②效果的目标和操作信息：选择墓地中的「堕天使」魔法·陷阱卡并发动其效果
function c52840267.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	-- 检查墓地中是否存在满足条件的「堕天使」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c52840267.cpfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要发动效果的墓地中的「堕天使」魔法·陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的墓地中的「堕天使」魔法·陷阱卡
	local g=Duel.SelectTarget(tp,c52840267.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	-- 清除当前连锁的目标卡片
	Duel.ClearTargetCard()
	g:GetFirst():CreateEffectRelation(e)
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前连锁的操作信息
	Duel.ClearOperationInfo(0)
	-- 设置②效果的操作信息：将选中的卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 执行②效果的处理：发动墓地中的卡的效果并将其送回卡组
function c52840267.cpop(e,tp,eg,ep,ev,re,r,rp)
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
