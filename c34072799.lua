--トランソニックバード
-- 效果：
-- 「音速的追赶者」降临。
-- ①：1回合1次，可以发动。手卡1张仪式魔法卡给对方观看，把1只在那张卡有卡名记述的仪式怪兽从卡组加入手卡，给人观看的卡回到卡组。
-- ②：对方回合1次，从卡组把1张仪式魔法卡送去墓地才能发动。这个效果变成和那张仪式魔法卡发动时的仪式召唤效果相同。
-- ③：仪式召唤的这张卡被解放的场合，以对方场上1张表侧表示的卡为对象才能发动。那张卡的效果直到回合结束时无效。
function c34072799.initial_effect(c)
	c:EnableReviveLimit()
	-- 效果①：1回合1次，可以发动。手卡1张仪式魔法卡给对方观看，把1只在那张卡有卡名记述的仪式怪兽从卡组加入手卡，给人观看的卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34072799,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c34072799.thtg)
	e1:SetOperation(c34072799.thop)
	c:RegisterEffect(e1)
	-- 效果②：对方回合1次，从卡组把1张仪式魔法卡送去墓地才能发动。这个效果变成和那张仪式魔法卡发动时的仪式召唤效果相同。
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
	-- 效果③：仪式召唤的这张卡被解放的场合，以对方场上1张表侧表示的卡为对象才能发动。那张卡的效果直到回合结束时无效。
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
-- 过滤函数，用于筛选手卡中满足条件的仪式魔法卡：必须是魔法卡且为仪式类型、可以送回卡组、且在卡组中存在对应的仪式怪兽。
function c34072799.tdfilter(c,tp)
	return bit.band(c:GetType(),0x82)==0x82 and c:IsAbleToDeck() and not c:IsPublic()
		-- 检查在卡组中是否存在满足条件的仪式怪兽，即该怪兽的卡名在所选的仪式魔法卡上有记载。
		and Duel.IsExistingMatchingCard(c34072799.thfilter,tp,LOCATION_DECK,0,1,nil,c)
end
-- 过滤函数，用于筛选卡组中满足条件的仪式怪兽：必须是怪兽卡且为仪式类型、可以加入手牌、且在所选的仪式魔法卡上有记载。
function c34072799.thfilter(c,mc)
	-- 检查所选的怪兽是否在所选的仪式魔法卡上有记载，即满足仪式召唤的条件。
	return bit.band(c:GetType(),0x81)==0x81 and c:IsAbleToHand() and aux.IsCodeListed(mc,c:GetCode())
end
-- 效果①的发动条件判断：检查手卡中是否存在满足条件的仪式魔法卡。
function c34072799.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在满足条件的仪式魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c34072799.tdfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 设置效果①的处理信息：将要送回卡组的卡。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	-- 设置效果①的处理信息：将要加入手牌的卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理函数：选择要送回卡组的仪式魔法卡，然后选择要加入手牌的仪式怪兽。
function c34072799.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的仪式魔法卡。
	local g1=Duel.SelectMatchingCard(tp,c34072799.tdfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	if g1:GetCount()==0 then return end
	-- 向对方玩家展示所选的仪式魔法卡。
	Duel.ConfirmCards(1-tp,g1)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的仪式怪兽。
	local g2=Duel.SelectMatchingCard(tp,c34072799.thfilter,tp,LOCATION_DECK,0,1,1,nil,g1:GetFirst())
	-- 如果成功将仪式怪兽加入手牌，则将仪式魔法卡送回卡组。
	if g2:GetCount()>0 and Duel.SendtoHand(g2,nil,REASON_EFFECT)~=0 then
		-- 向对方玩家展示所选的仪式怪兽。
		Duel.ConfirmCards(1-tp,g2)
		-- 将仪式魔法卡送回卡组并洗牌。
		Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 效果②的发动条件判断：当前回合不是自己回合。
function c34072799.rscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否不是自己。
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤函数，用于筛选卡组中满足条件的仪式魔法卡：必须是魔法卡且为仪式类型、可以送去墓地、且可以发动。
function c34072799.cfilter(c)
	return c:GetType()==TYPE_SPELL+TYPE_RITUAL and c:IsAbleToGraveAsCost() and c:CheckActivateEffect(true,true,false)~=nil
end
-- 效果②的发动费用处理函数：设置标签为1，表示已支付费用。
function c34072799.rscost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 效果②的发动处理函数：选择要送去墓地的仪式魔法卡，并复制其发动时的效果。
function c34072799.rstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		-- 检查卡组中是否存在满足条件的仪式魔法卡。
		return Duel.IsExistingMatchingCard(c34072799.cfilter,tp,LOCATION_DECK,0,1,nil)
	end
	e:SetLabel(0)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的仪式魔法卡。
	local g=Duel.SelectMatchingCard(tp,c34072799.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	local te=g:GetFirst():CheckActivateEffect(true,true,false)
	e:SetLabelObject(te)
	-- 将所选的仪式魔法卡送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	-- 清除当前处理的连锁的操作信息。
	Duel.ClearOperationInfo(0)
end
-- 效果②的发动处理函数：执行复制的仪式魔法卡的发动效果。
function c34072799.rsop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
-- 效果③的发动条件判断：判断此卡是否为仪式召唤。
function c34072799.negcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 效果③的发动处理函数：选择对方场上的一张表侧表示的卡作为对象。
function c34072799.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断所选对象是否为对方场上的卡且可以被无效化。
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	-- 检查对方场上是否存在可以被无效化的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要无效的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择满足条件的对方场上的卡。
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果③的处理信息：将要无效的卡。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果③的处理函数：使目标卡的效果无效。
function c34072799.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使目标卡相关的连锁无效化。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 创建一个使目标卡无效的永续效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 创建一个使目标卡的效果无效的永续效果。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 如果目标卡为陷阱怪兽，则创建一个使其无效的永续效果。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
