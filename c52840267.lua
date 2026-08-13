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
-- 过滤函数：判断手牌中的卡是否为「堕天使」卡且可以被丢弃。
function c52840267.cfilter(c)
	return c:IsSetCard(0xef) and c:IsDiscardable()
end
-- 代价检查：确认这张卡自身在手牌可丢弃，且手牌中还存在另一张可丢弃的「堕天使」卡。
function c52840267.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable()
		-- 代价检查：确认手牌中存在至少1张满足条件的「堕天使」卡（不包含这张卡自身）。
		and Duel.IsExistingMatchingCard(c52840267.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示玩家从手牌选择要丢弃的卡，显示选择框提示文字“请选择要丢弃的手牌”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 玩家从手牌选择1张满足条件的「堕天使」卡（不能选这张卡自身）。
	local g=Duel.SelectMatchingCard(tp,c52840267.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 将选择的「堕天使」卡与这张卡自身一起送去墓地，作为丢弃代价。
	Duel.SendtoGrave(g,REASON_DISCARD+REASON_COST)
end
-- 抽卡效果的发动条件与目标设定：确认能抽2张，将对象玩家设为自身、抽卡数设为2，并设置抽卡的操作信息。
function c52840267.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己是否可以抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的对象玩家设置为自己，表示由自己抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为2，表示抽卡数量为2。
	Duel.SetTargetParam(2)
	-- 设置操作信息：本次效果包含抽卡效果，预计抽卡数为2，抽卡玩家为自己。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理：取出之前设置的抽卡玩家和抽卡数量，让该玩家抽对应数量的卡。
function c52840267.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家和对象参数，即抽卡玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- ②效果的代价：确认可以支付1000基本分，然后实际支付1000基本分。
function c52840267.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己是否能够支付1000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际支付1000基本分作为发动代价。
	Duel.PayLPCost(tp,1000)
end
-- 过滤函数：墓地中存在「堕天使」魔法·陷阱卡，且该卡能回到卡组、并且自身包含可发动的效果（用于复制效果）。
function c52840267.cpfilter(c)
	return c:IsSetCard(0xef) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck() and c:CheckActivateEffect(false,true,false)~=nil
end
-- ②效果的目标选择与复制准备：选择墓地中的「堕天使」魔法·陷阱卡作为对象，记录其发动效果，清除原先的操作信息，改为设置回卡组的操作信息；同时处理追加对象条件。
function c52840267.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	-- 发动条件检查：墓地中是否存在1张可作为对象的「堕天使」魔法·陷阱卡，且该卡有效果可复制、能回卡组。
	if chk==0 then return Duel.IsExistingTarget(c52840267.cpfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家从墓地选择要复制的效果对象，显示“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家从自己墓地选择1张满足条件的「堕天使」魔法·陷阱卡作为对象。
	local g=Duel.SelectTarget(tp,c52840267.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	-- 清除当前连锁已设置的对象卡，因为后续要重新建立复制效果的对象联系。
	Duel.ClearTargetCard()
	g:GetFirst():CreateEffectRelation(e)
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前连锁的操作信息，避免复制来的效果附带无关信息。
	Duel.ClearOperationInfo(0)
	-- 设置操作信息：本次效果处理后会将对象卡返回持有者卡组，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ②效果处理：取得被复制的效果，若对象仍与效果关联则执行其效果处理；处理完成后中断连锁时点，将墓地中那张「堕天使」魔法·陷阱卡返回卡组洗牌。
function c52840267.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	if not te:GetHandler():IsRelateToEffect(e) then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
	-- 中断当前效果处理，使后续回卡组处理视为不同时处理，制造错时点。
	Duel.BreakEffect()
	-- 将被复制的效果对应的那张墓地卡返回持有者卡组，并洗切卡组。
	Duel.SendtoDeck(te:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
