--三戦の才
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：这个回合的自己主要阶段对方是已把怪兽的效果发动的场合，可以从以下效果选择1个发动。
-- ●自己抽2张。
-- ●对方场上1只怪兽的控制权直到结束阶段得到。
-- ●把对方手卡确认，选那之内的1张回到卡组。
function c25311006.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,25311006+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c25311006.condition)
	e1:SetTarget(c25311006.target)
	e1:SetOperation(c25311006.operation)
	c:RegisterEffect(e1)
	-- 设置计数器，用于记录对方在主要阶段发动怪兽效果的次数。
	Duel.AddCustomActivityCounter(25311006,ACTIVITY_CHAIN,c25311006.chainfilter)
end
-- 过滤函数，用于判断是否为怪兽效果且在主要阶段发动。
function c25311006.chainfilter(re,tp,cid)
	-- 获取当前阶段。
	local ph=Duel.GetCurrentPhase()
	return not (re:IsActiveType(TYPE_MONSTER) and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2))
end
-- 效果原文内容：①：这个回合的自己主要阶段对方是已把怪兽的效果发动的场合，可以从以下效果选择1个发动。
function c25311006.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方是否在主要阶段发动过怪兽效果。
	return Duel.GetCustomActivityCount(25311006,1-tp,ACTIVITY_CHAIN)~=0
end
-- 效果原文内容：●自己抽2张。●对方场上1只怪兽的控制权直到结束阶段得到。●把对方手卡确认，选那之内的1张回到卡组。
function c25311006.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以抽2张卡。
	local b1=Duel.IsPlayerCanDraw(tp,2)
	-- 检查对方场上是否存在可改变控制权的怪兽。
	local b2=Duel.IsExistingMatchingCard(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil)
	-- 检查对方手牌是否存在。
	local b3=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
	if chk==0 then return b1 or b2 or b3 end
	local off=1
	local ops={}
	local opval={}
	if b1 then
		ops[off]=aux.Stringid(25311006,0)  --"自己抽2张"
		opval[off-1]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(25311006,1)  --"对方场上1只怪兽的控制权直到结束阶段得到"
		opval[off-1]=2
		off=off+1
	end
	if b3 then
		ops[off]=aux.Stringid(25311006,2)  --"把对方手卡确认，选那之内的1张回到卡组"
		opval[off-1]=3
		off=off+1
	end
	-- 提示玩家选择发动的效果。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)  --"请选择要发动的效果"
	-- 让玩家选择发动的效果。
	local op=Duel.SelectOption(tp,table.unpack(ops))
	e:SetLabel(opval[op])
	if opval[op]==1 then
		e:SetCategory(CATEGORY_DRAW)
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		-- 设置效果的目标玩家为发动者。
		Duel.SetTargetPlayer(tp)
		-- 设置效果的目标参数为2。
		Duel.SetTargetParam(2)
		-- 设置效果操作信息为抽2张卡。
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	elseif opval[op]==2 then
		e:SetCategory(CATEGORY_CONTROL)
		e:SetProperty(0)
		-- 获取对方场上的可改变控制权的怪兽组。
		local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE):Filter(Card.IsControlerCanBeChanged,nil)
		-- 设置效果操作信息为获得怪兽控制权。
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	elseif opval[op]==3 then
		e:SetCategory(CATEGORY_TODECK)
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		-- 设置效果的目标玩家为发动者。
		Duel.SetTargetPlayer(tp)
		-- 设置效果操作信息为将对方手牌送回卡组。
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,1-tp,LOCATION_HAND)
	end
end
-- 根据选择的效果执行对应操作。
function c25311006.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		c25311006.draw(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		c25311006.control(e,tp,eg,ep,ev,re,r,rp)
	elseif op==3 then
		c25311006.todeck(e,tp,eg,ep,ev,re,r,rp)
	end
end
-- 执行抽卡效果。
function c25311006.draw(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁信息中的目标玩家和目标参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 执行获得怪兽控制权效果。
function c25311006.control(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要改变控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上的1只可改变控制权的怪兽。
	local g=Duel.SelectMatchingCard(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		-- 显示所选怪兽被选为对象的动画。
		Duel.HintSelection(g)
		-- 获得所选怪兽的控制权直到结束阶段。
		Duel.GetControl(g:GetFirst(),tp,PHASE_END,1)
	end
end
-- 执行将对方手牌送回卡组效果。
function c25311006.todeck(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁信息中的目标玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取对方手牌组。
	local g=Duel.GetFieldGroup(p,0,LOCATION_HAND)
	if #g>0 then
		-- 确认对方手牌。
		Duel.ConfirmCards(p,g)
		-- 提示玩家选择要送回卡组的卡。
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=g:FilterSelect(p,Card.IsAbleToDeck,1,1,nil)
		if #sg<=0 then return end
		-- 将所选卡送回卡组。
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 洗切对方手牌。
		Duel.ShuffleHand(1-p)
	end
end
