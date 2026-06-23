--トランソニックバード
-- 效果：
-- 「音速的追赶者」降临。
-- ①：1回合1次，可以发动。手卡1张仪式魔法卡给对方观看，把1只在那张卡有卡名记述的仪式怪兽从卡组加入手卡，给人观看的卡回到卡组。
-- ②：对方回合1次，从卡组把1张仪式魔法卡送去墓地才能发动。这个效果变成和那张仪式魔法卡发动时的仪式召唤效果相同。
-- ③：仪式召唤的这张卡被解放的场合，以对方场上1张表侧表示的卡为对象才能发动。那张卡的效果直到回合结束时无效。
function c34072799.initial_effect(c)
	-- 注册卡片密码17888577（音速的追赶者）至当前卡片的记载卡密码列表中。
	aux.AddCodeList(c,17888577)
	c:EnableReviveLimit()
	-- ①：1回合1次，可以发动。手卡1张仪式魔法卡给对方观看，把1只在那张卡有卡名记述的仪式怪兽从卡组加入手卡，给人观看的卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34072799,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c34072799.thtg)
	e1:SetOperation(c34072799.thop)
	c:RegisterEffect(e1)
	-- ②：对方回合1次，从卡组把1张仪式魔法卡送去墓地才能发动。这个效果变成和那张仪式魔法卡发动时的仪式召唤效果相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34072799,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(c34072799.rscon)
	e2:SetCost(c34072799.rscost)
	e2:SetTarget(c34072799.rstg)
	e2:SetOperation(c34072799.rsop)
	c:RegisterEffect(e2)
	-- ③：仪式召唤的这张卡被解放的场合，以对方场上1张表侧表示的卡为对象才能发动。那张卡的效果直到回合结束时无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34072799,2))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_RELEASE)
	e3:SetCondition(c34072799.negcon)
	e3:SetTarget(c34072799.negtg)
	e3:SetOperation(c34072799.negop)
	c:RegisterEffect(e3)
end
-- 过滤函数，筛选手牌中非公开的、能作为返回卡组对象且其所记述的仪式怪兽存在于卡组中的仪式魔法卡。
function c34072799.tdfilter(c,tp)
	return bit.band(c:GetType(),0x82)==0x82 and c:IsAbleToDeck() and not c:IsPublic()
		-- 检查卡组中是否存在可以通过被展示卡检索的符合条件的仪式怪兽。
		and Duel.IsExistingMatchingCard(c34072799.thfilter,tp,LOCATION_DECK,0,1,nil,c)
end
-- 过滤函数，筛选卡组中能被指定的展示仪式魔法卡所记载了卡名的、且可加入手牌的仪式怪兽。
function c34072799.thfilter(c,mc)
	-- 判断卡片是否为仪式怪兽、可加入手牌，并且其卡片密码被展示卡片（mc）的效果文本所记述。
	return bit.band(c:GetType(),0x81)==0x81 and c:IsAbleToHand() and aux.IsCodeListed(mc,c:GetCode())
end
-- 效果①的发动目标处理，检查手牌是否存在可用的展示仪式魔法卡，并注册将手卡送回卡组以及从卡组检索手牌的操作信息。
function c34072799.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1张满足展示并能从卡组检索其所记载仪式怪兽的仪式魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c34072799.tdfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 设置操作信息：将手牌中的1张卡送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的具体处理逻辑，选择手牌1张仪式魔法给对方观看，检索其记述的1只仪式怪兽加入手卡，最后将展示的魔法送回卡组。
function c34072799.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择送回卡组的手牌卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从玩家手牌中选取1张可作为仪式检索条件的仪式魔法卡。
	local g1=Duel.SelectMatchingCard(tp,c34072799.tdfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	if g1:GetCount()==0 then return end
	-- 将选中的手卡给对方玩家确认。
	Duel.ConfirmCards(1-tp,g1)
	-- 提示玩家从卡组选择要加入手牌的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只由展示的仪式魔法卡所记载的仪式怪兽。
	local g2=Duel.SelectMatchingCard(tp,c34072799.thfilter,tp,LOCATION_DECK,0,1,1,nil,g1:GetFirst())
	-- 若所选的仪式怪兽成功加入手牌，则继续处理将原展示的仪式魔法卡送回卡组的后续操作。
	if g2:GetCount()>0 and Duel.SendtoHand(g2,nil,REASON_EFFECT)~=0 then
		-- 将检索到的仪式怪兽给对方玩家确认。
		Duel.ConfirmCards(1-tp,g2)
		-- 将最初选中的那张展示的仪式魔法卡送回卡组并洗牌。
		Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 效果②的发动条件，限制只能在对方的回合发动。
function c34072799.rscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家是否不是当前回合的持有者（即为对方回合）。
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤函数，筛选卡组中属于仪式魔法、可以送去墓地且具有可被激活的卡片效果的卡片。
function c34072799.cfilter(c)
	return c:GetType()==TYPE_SPELL+TYPE_RITUAL and c:IsAbleToGraveAsCost() and c:CheckActivateEffect(true,true,false)~=nil
end
-- 效果②的发动代价注册，通过将Label设为1来绕过发动时的常规卡片检测限制。
function c34072799.rscost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 效果②的发动目标与代价扣除处理，让玩家选择卡组中1张仪式魔法卡送去墓地，并获取其效果对象以进行复制。
function c34072799.rstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		-- 检测自己卡组中是否存在可送去墓地并复制效果的仪式魔法卡。
		return Duel.IsExistingMatchingCard(c34072799.cfilter,tp,LOCATION_DECK,0,1,nil)
	end
	e:SetLabel(0)
	-- 提示玩家选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组中选择1张符合条件的仪式魔法卡。
	local g=Duel.SelectMatchingCard(tp,c34072799.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	local te=g:GetFirst():CheckActivateEffect(true,true,false)
	e:SetLabelObject(te)
	-- 将选中的仪式魔法卡送去墓地作为发动的代价。
	Duel.SendtoGrave(g,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	-- 清除由于复制效果而产生的无关联锁操作信息，防止被非正常响应。
	Duel.ClearOperationInfo(0)
end
-- 效果②的具体处理逻辑，直接调用获取到的仪式魔法卡的激活效果来代替其自身执行。
function c34072799.rsop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
-- 效果③的发动条件，必须是仪式召唤的这张卡被解放的场合。
function c34072799.negcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 效果③的发动目标处理，选择对方场上1张表侧表示的卡为对象，并注册无效化卡片的操作信息。
function c34072799.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 作为对象的目标卡片判定，要求其必须由对方控制、存在于场上且可被无效。
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	-- 检查对方场上是否存在至少1张可以作为被无效对象的目标卡片。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要使效果无效的卡片对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家在对方场上选择1张可成为无效对象的表侧表示卡片。
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：使选定的卡片效果无效。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果③的具体处理逻辑，使选中的卡片效果直到回合结束时无效。
function c34072799.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取被本连锁选定的第一个对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
		-- 无效化所有与目标卡片相关的仍在处理中的效果连锁。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那张卡的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那张卡的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 那张卡的效果直到回合结束时无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
