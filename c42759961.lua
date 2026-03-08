--道化の一座 フレア
-- 效果：
-- 「道化一座」卡降临
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从卡组把仪式怪兽以外的1张「道化一座」卡加入手卡。那之后，选自己1张手卡丢弃。
-- ②：这张卡被解放的场合，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●双方的场上·墓地的仪式怪兽全部回到卡组。
-- ●场上1只效果怪兽变成里侧守备表示。
local s,id,o=GetID()
-- 初始化卡片效果，注册①②两个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：把手卡的这张卡给对方观看才能发动。从卡组把仪式怪兽以外的1张「道化一座」卡加入手卡。那之后，选自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡被解放的场合，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。●双方的场上·墓地的仪式怪兽全部回到卡组。●场上1只效果怪兽变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"选择效果"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 效果发动时的费用检查，确认手卡的这张卡是否已公开
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 检索过滤函数，筛选卡名包含「道化一座」且不是仪式怪兽的卡
function s.thfilter(c)
	return c:IsSetCard(0x1dc) and not (c:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER)) and c:IsAbleToHand()
end
-- 设置①效果的发动条件和操作信息，检查卡组是否存在符合条件的卡并设置回手和丢弃操作
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡从卡组加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置丢弃手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- ①效果的处理函数，选择卡加入手牌并丢弃手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择符合条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
			-- 提示玩家选择要丢弃的手牌
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
			-- 选择要丢弃的手牌
			local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_EFFECT)
			-- 洗切玩家手牌
			Duel.ShuffleHand(tp)
			if dg:GetCount()>0 then
				-- 中断当前效果处理
				Duel.BreakEffect()
				-- 将选中的手牌送去墓地
				Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
			end
		end
	end
end
-- ②效果的检索过滤函数，筛选场上或墓地的仪式怪兽
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER) and c:IsAbleToDeck()
end
-- ②效果的检索过滤函数，筛选场上效果怪兽
function s.posfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsCanTurnSet()
end
-- ②效果的发动条件和操作信息设置，判断是否可以发动两个选项并设置操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上或墓地是否存在仪式怪兽
	local b1=Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,1,nil)
		-- 判断是否已使用过该效果（通过标识效果）
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	-- 判断场上是否存在效果怪兽
	local b2=Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 判断是否已使用过该效果（通过标识效果）
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o)==0)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家选择发动哪个效果
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"仪式怪兽回到卡组"
			{b2,aux.Stringid(id,3),2})  --"盖放怪兽"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TODECK)
			-- 注册标识效果，防止该效果在本回合再次发动
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 获取符合条件的仪式怪兽组
		local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,nil)
		-- 设置将仪式怪兽送回卡组的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,LOCATION_GRAVE+LOCATION_MZONE)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
			-- 注册标识效果，防止该效果在本回合再次发动
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 获取符合条件的效果怪兽组
		local g=Duel.GetMatchingGroup(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 设置将效果怪兽变为里侧守备表示的操作信息
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	end
end
-- ②效果的处理函数，根据选择的效果执行相应操作
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 获取符合条件的仪式怪兽组
		local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,nil)
		-- 检查是否被王家长眠之谷保护，若被保护则中断效果
		if aux.NecroValleyNegateCheck(g) then return end
		-- 将仪式怪兽送回卡组
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要变为里侧守备表示的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 选择要变为里侧守备表示的怪兽
		local sg=Duel.SelectMatchingCard(tp,s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if sg:GetCount()>0 then
			-- 显示选中的怪兽被选为对象
			Duel.HintSelection(sg)
			local tc=sg:GetFirst()
			-- 将选中的怪兽变为里侧守备表示
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		end
	end
end
