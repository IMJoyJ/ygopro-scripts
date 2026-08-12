--三幻魔の天壊
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●对方连锁自己的「三幻魔」怪兽的效果的发动把效果发动时才能发动。那个对方的效果无效。
-- ●把手卡1只10星「三幻魔」怪兽给对方观看才能发动。选自己1张手卡丢弃，从卡组把1张「幻魔之扉」加入手卡。
-- ●让自己的墓地·除外状态的3张「三幻魔」陷阱卡回到卡组，以对方场上1张卡为对象才能发动。那张卡破坏。
local s,id,o=GetID()
-- 初始化卡片效果：记录关联卡名，创建并注册一个自由时点发动的通常陷阱发动效果，并设定其分类、取对象标记、代价、对象和处理函数
function s.initial_effect(c)
	-- 记录这张卡上记载着「幻魔之扉」（卡号33017964）的卡名
	aux.AddCodeList(c,33017964)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
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
-- 过滤器：检索用的筛选条件，要求卡是「幻魔之扉」且可以加入手卡
function s.thfilter(c)
	return c:IsCode(33017964) and c:IsAbleToHand()
end
-- 代价过滤器：手卡中给对方观看用，要求是不公开的10星「三幻魔」怪兽
function s.costfilter1(c)
	return c:IsSetCard(0x1144) and c:IsLevel(10) and not c:IsPublic()
end
-- 代价过滤器：要求是自己墓地或除外状态的表侧表示「三幻魔」陷阱卡，且可以作为代价返回卡组
function s.costfilter2(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1144) and c:IsType(TYPE_TRAP) and c:IsAbleToDeckAsCost()
end
-- 代价函数：依次判断3个效果分支（无效、检索、破坏）各自是否可发动，让玩家选择1个分支，并在选择检索分支时给对方观看手卡的10星「三幻魔」怪兽、选择破坏分支时把墓地·除外的3张「三幻魔」陷阱卡返回卡组作为代价
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=false
	-- 获取当前正在处理的连锁序号
	local ch=Duel.GetCurrentChain()
	local og=Group.CreateGroup()
	local tsp=-1
	local tse=nil
	if e:GetHandler():IsStatus(STATUS_CHAINING) then ch=ch-1 end
	if ch>1 then
		-- 获取该连锁的发动玩家和发动的效果，用于判断是否是对方发动的效果
		tsp,tse=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_EFFECT)
		og:AddCard(tse:GetHandler())
		-- 判断该连锁是否由对方发动，且要无效的那个连锁的效果可以被无效
		if tsp==1-tp and Duel.IsChainDisablable(ev) then
			-- 获取前一个连锁（即被连锁的效果）的效果对象和发动玩家，用于判断是否是自己的「三幻魔」怪兽效果
			local te,p=Duel.GetChainInfo(ch-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
			b1=(te and te:GetHandler():IsSetCard(0x1144) and te:IsActiveType(TYPE_MONSTER) and p==tp)
		end
	end
	-- 分支2判断：自己手卡是否存在可以给对方观看的10星「三幻魔」怪兽
	local b2=Duel.IsExistingMatchingCard(s.costfilter1,tp,LOCATION_HAND,0,1,nil)
		-- 分支2判断：自己手卡数量大于0（有可以丢弃的手卡）
		and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
		-- 分支2判断：卡组是否存在可以加入手卡的「幻魔之扉」
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	-- 分支3判断：自己墓地·除外状态是否存在至少3张可以返回卡组的「三幻魔」陷阱卡
	local b3=Duel.IsExistingMatchingCard(s.costfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil)
		-- 分支3判断：对方场上是否存在可以作为效果对象的卡
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	if chk==0 then return b1 or b2 or b3 end
	-- 让玩家从3个效果分支中选择1个发动
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1),1},  --"效果无效"
		{b2,aux.Stringid(id,2),2},  --"检索效果"
		{b3,aux.Stringid(id,3),3})  --"破坏效果"
	e:SetLabel(op,1)
	if op==2 then
		-- 提示玩家选择要给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 让自己从手卡选择1只10星「三幻魔」怪兽
		local g=Duel.SelectMatchingCard(tp,s.costfilter1,tp,LOCATION_HAND,0,1,1,nil)
		-- 给对方确认选择的卡（把手卡的10星「三幻魔」怪兽给对方观看）
		Duel.ConfirmCards(1-tp,g)
		-- 手动洗切自己的手卡
		Duel.ShuffleHand(tp)
	elseif op==3 then
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 让自己从墓地·除外状态选择3张「三幻魔」陷阱卡
		local g=Duel.SelectMatchingCard(tp,s.costfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,3,nil)
		-- 为选择的卡显示被选中的动画并记录这些卡
		Duel.HintSelection(g)
		-- 作为代价把选择的3张卡返回卡组并洗切卡组
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	end
end
-- 对象函数：重新判断3个分支的可用性，确定本次发动的分支，并按分支设置效果分类、操作信息；破坏分支时让对方选1张场上的卡为对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	local b1=false
	-- 获取当前正在处理的连锁序号
	local ch=Duel.GetCurrentChain()
	local og=Group.CreateGroup()
	local tsp=-1
	local tse=nil
	if e:GetHandler():IsStatus(STATUS_CHAINING) then ch=ch-1 end
	if ch>1 then
		-- 获取该连锁的发动玩家和发动的效果，用于判断是否是对方发动的效果
		tsp,tse=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_EFFECT)
		og:AddCard(tse:GetHandler())
		-- 判断该连锁是否由对方发动，且要无效的那个连锁的效果可以被无效
		if tsp==1-tp and Duel.IsChainDisablable(ev) then
			-- 获取前一个连锁（即被连锁的效果）的效果对象和发动玩家，用于判断是否是自己的「三幻魔」怪兽效果
			local te,p=Duel.GetChainInfo(ch-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
			b1=(te and te:GetHandler():IsSetCard(0x1144) and te:IsActiveType(TYPE_MONSTER) and p==tp)
		end
	end
	-- 分支2判断：自己手卡数量大于0（有可以丢弃的手卡）
	local b2=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
		-- 分支2判断：卡组是否存在可以加入手卡的「幻魔之扉」
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	-- 分支3判断：对方场上是否存在可以作为效果对象的卡
	local b3=Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	if chk==0 then return b1 or ((b2 or b3) and not e:IsCostChecked()) or e:IsCostChecked() end
	local op,el=e:GetLabel()
	if el==0 then
		-- 代价未处理时，让玩家从3个效果分支中选择1个发动
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"效果无效"
			{b2,aux.Stringid(id,2),2},  --"检索效果"
			{b3,aux.Stringid(id,3),3})  --"破坏效果"
	end
	e:SetLabel(op,0)
	if op==1 then
		e:SetCategory(CATEGORY_DISABLE)
		e:SetProperty(0)
		-- 设置操作信息：本次连锁将把对方那个效果的发动无效（无效效果分类，对象为对方发动效果的卡）
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,og,1,0,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES_SELF)
		e:SetProperty(0)
		-- 设置操作信息：效果处理时自己将丢弃1张手卡
		Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
		-- 设置操作信息：效果处理时将从卡组把1张卡加入手卡
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==3 then
		e:SetCategory(CATEGORY_DESTROY)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 以对方场上1张卡为对象（同时设为当前连锁的对象）
		local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
		-- 设置操作信息：效果处理时将破坏作为对象的那1张卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果处理函数：根据选择的分支分别处理——分支1把对方连锁的效果无效，分支2让自己丢弃1张手卡后从卡组把「幻魔之扉」加入手卡并给对方确认，分支3破坏作为对象的对方场上的卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 获取当前正在处理的连锁序号
		local ch=Duel.GetCurrentChain()
		-- 把前一个连锁（对方连锁自己的「三幻魔」怪兽效果发动的那个效果）无效
		Duel.NegateEffect(ch-1)
	elseif e:GetLabel()==2 then
		-- 让自己选择1张手卡以效果丢弃，成功丢弃才继续处理检索
		if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)~=0 then
			-- 提示玩家选择要加入手卡的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 让自己从卡组选择1张「幻魔之扉」
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			if g:GetCount()>0 then
				-- 把选择的「幻魔之扉」加入自己的手卡
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				-- 给对方确认加入手卡的那张卡
				Duel.ConfirmCards(1-tp,g)
			end
		end
	elseif e:GetLabel()==3 then
		-- 取得当前连锁的对象卡（对方场上被选择的那1张卡）
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToChain() and tc:IsOnField() then
			-- 以效果破坏那张对象卡
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
