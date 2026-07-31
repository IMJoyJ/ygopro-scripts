--三幻魔の天壊
local s,id,o=GetID()
-- 初始化效果，注册卡片效果
function s.initial_effect(c)
	-- 记录该卡具有33017964这张卡的名称
	aux.AddCodeList(c,33017964)
	-- 设置效果描述、分类、类型、触发时机、次数限制、属性、费用函数、目标函数和发动函数
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE+TIMING_CHAIN_END)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡（33017964且能加入手牌）
function s.thfilter(c)
	return c:IsCode(33017964) and c:IsAbleToHand()
end
-- 费用过滤器1：检查手牌中是否存在10星且未公开的幻魔族卡
function s.costfilter1(c)
	return c:IsSetCard(0x1144) and c:IsLevel(10) and not c:IsPublic()
end
-- 费用过滤器2：检查墓地或除外区是否存在3张以上幻魔族陷阱卡
function s.costfilter2(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1144) and c:IsType(TYPE_TRAP) and c:IsAbleToDeckAsCost()
end
-- 设置发动时的费用选择，提供三种费用选项并执行对应操作
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=false
	-- 获取当前连锁序号
	local ch=Duel.GetCurrentChain()
	local og=Group.CreateGroup()
	local tsp=-1
	local tse=nil
	if e:GetHandler():IsStatus(STATUS_CHAINING) then ch=ch-1 end
	if ch>1 then
		-- 获取当前连锁的触发玩家和效果
		tsp,tse=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_EFFECT)
		og:AddCard(tse:GetHandler())
		-- 判断是否为对方触发且该连锁可被无效
		if tsp==1-tp and Duel.IsChainDisablable(ev) then
			-- 获取上一个连锁的效果和触发玩家
			local te,p=Duel.GetChainInfo(ch-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
			b1=(te and te:GetHandler():IsSetCard(0x1144) and te:IsActiveType(TYPE_MONSTER) and p==tp)
		end
	end
	-- 检查手牌中是否存在满足条件的卡
	local b2=Duel.IsExistingMatchingCard(s.costfilter1,tp,LOCATION_HAND,0,1,nil)
		-- 检查手牌数量大于0
		and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
		-- 检查卡组中是否存在满足条件的卡
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	-- 检查墓地或除外区是否存在满足条件的卡
	local b3=Duel.IsExistingMatchingCard(s.costfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil)
		-- 检查场上是否存在目标卡
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	if chk==0 then return b1 or b2 or b3 end
	-- 让玩家选择费用选项
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1),1},
		{b2,aux.Stringid(id,2),2},
		{b3,aux.Stringid(id,3),3})
	e:SetLabel(op,1)
	if op==2 then
		-- 提示玩家选择要确认给对方的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 选择要确认给对方的卡
		local g=Duel.SelectMatchingCard(tp,s.costfilter1,tp,LOCATION_HAND,0,1,1,nil)
		-- 向对方确认所选卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自己的手牌
		Duel.ShuffleHand(tp)
	elseif op==3 then
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择要返回卡组的卡
		local g=Duel.SelectMatchingCard(tp,s.costfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,3,nil)
		-- 显示被选为对象的动画效果
		Duel.HintSelection(g)
		-- 将卡送回卡组并洗切
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	end
end
-- 设置发动时的目标选择，提供三种目标选项并设置对应操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	local b1=false
	-- 获取当前连锁序号
	local ch=Duel.GetCurrentChain()
	local og=Group.CreateGroup()
	local tsp=-1
	local tse=nil
	if e:GetHandler():IsStatus(STATUS_CHAINING) then ch=ch-1 end
	if ch>1 then
		-- 获取当前连锁的触发玩家和效果
		tsp,tse=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_EFFECT)
		og:AddCard(tse:GetHandler())
		-- 判断是否为对方触发且该连锁可被无效
		if tsp==1-tp and Duel.IsChainDisablable(ev) then
			-- 获取上一个连锁的效果和触发玩家
			local te,p=Duel.GetChainInfo(ch-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
			b1=(te and te:GetHandler():IsSetCard(0x1144) and te:IsActiveType(TYPE_MONSTER) and p==tp)
		end
	end
	-- 检查手牌数量大于0
	local b2=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
		-- 检查卡组中是否存在满足条件的卡
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	-- 检查场上是否存在目标卡
	local b3=Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	if chk==0 then return b1 or ((b2 or b3) and not e:IsCostChecked()) or e:IsCostChecked() end
	local op,el=e:GetLabel()
	if el==0 then
		-- 让玩家选择目标选项
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},
			{b2,aux.Stringid(id,2),2},
			{b3,aux.Stringid(id,3),3})
	end
	e:SetLabel(op,0)
	if op==1 then
		e:SetCategory(CATEGORY_DISABLE)
		e:SetProperty(0)
		-- 设置操作信息为使效果无效
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,og,1,0,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES_SELF)
		e:SetProperty(0)
		-- 设置操作信息为丢弃手牌
		Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
		-- 设置操作信息为加入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==3 then
		e:SetCategory(CATEGORY_DESTROY)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择要破坏的目标卡
		local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
		-- 设置操作信息为破坏目标卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 设置发动时的效果处理，根据选择的选项执行不同效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 获取当前连锁序号
		local ch=Duel.GetCurrentChain()
		-- 使上一个连锁的效果无效
		Duel.NegateEffect(ch-1)
	elseif e:GetLabel()==2 then
		-- 丢弃一张手牌
		if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)~=0 then
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 选择要加入手牌的卡
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			if g:GetCount()>0 then
				-- 将卡送入手牌
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				-- 向对方确认所选卡
				Duel.ConfirmCards(1-tp,g)
			end
		end
	elseif e:GetLabel()==3 then
		-- 获取当前连锁的目标卡
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToChain() and tc:IsOnField() then
			-- 破坏目标卡
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
