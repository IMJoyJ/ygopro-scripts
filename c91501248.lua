--禁忌の壺
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡反转的场合，可以从以下效果选择1个发动。
-- ●自己抽2张。
-- ●场上的魔法·陷阱卡全部回到手卡。
-- ●对方场上的怪兽全部破坏。
-- ●把对方手卡确认，选那之内的1张回到卡组。
function c91501248.initial_effect(c)
	-- ①：这张卡反转的场合，可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,91501248)
	e1:SetTarget(c91501248.target)
	e1:SetOperation(c91501248.operation)
	c:RegisterEffect(e1)
end
-- 过滤场上可以回到手牌的魔法、陷阱卡
function c91501248.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果①的Target函数：检查可行选项，并让玩家选择其中一个效果发动，设置对应的操作信息
function c91501248.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以抽2张卡（对应选项1的可行性）
	local b1=Duel.IsPlayerCanDraw(tp,2)
	-- 检查场上是否存在可以回到手牌的魔法、陷阱卡（对应选项2的可行性）
	local b2=Duel.IsExistingMatchingCard(c91501248.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	-- 检查对方场上是否存在怪兽（对应选项3的可行性）
	local b3=Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
	-- 检查对方手牌是否可以回到卡组（对应选项4的可行性）
	local b4=Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND,1,nil)
	if chk==0 then return b1 or b2 or b3 or b4 end
	local off=1
	local ops={}
	local opval={}
	if b1 then
		ops[off]=aux.Stringid(91501248,0)  --"自己抽2张"
		opval[off-1]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(91501248,1)  --"场上的魔法·陷阱卡全部回到手卡"
		opval[off-1]=2
		off=off+1
	end
	if b3 then
		ops[off]=aux.Stringid(91501248,2)  --"对方场上的怪兽全部破坏"
		opval[off-1]=3
		off=off+1
	end
	if b4 then
		ops[off]=aux.Stringid(91501248,3)  --"把对方手卡确认，选那之内的1张回到卡组"
		opval[off-1]=4
		off=off+1
	end
	-- 让玩家从可行的选项中选择一个发动
	local op=Duel.SelectOption(tp,table.unpack(ops))
	local sel=opval[op]
	e:SetLabel(sel)
	if sel==1 then
		e:SetCategory(CATEGORY_DRAW)
		-- 设置当前连锁的目标玩家为自己
		Duel.SetTargetPlayer(tp)
		-- 设置当前连锁的目标参数为2（抽卡张数）
		Duel.SetTargetParam(2)
		-- 设置当前连锁的操作信息为：自己抽2张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	elseif sel==2 then
		e:SetCategory(CATEGORY_TOHAND)
		-- 获取场上所有可以回到手牌的魔法、陷阱卡
		local g=Duel.GetMatchingGroup(c91501248.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		-- 设置当前连锁的操作信息为：将场上的魔法、陷阱卡全部回到手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
	elseif sel==3 then
		e:SetCategory(CATEGORY_DESTROY)
		-- 获取对方场上的所有怪兽
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		-- 设置当前连锁的操作信息为：破坏对方场上的所有怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	else
		e:SetCategory(CATEGORY_TODECK)
		-- 设置当前连锁的目标玩家为自己（用于确认对方手牌）
		Duel.SetTargetPlayer(tp)
		-- 设置当前连锁的操作信息为：将对方手牌中的1张卡送回卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,1-tp,LOCATION_HAND)
	end
end
-- 效果①的Operation函数：根据玩家在发动时选择的选项，执行对应的效果处理
function c91501248.operation(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==1 then
		-- 获取当前连锁的目标玩家和目标参数（抽卡张数）
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 让目标玩家因效果抽指定张数的卡
		Duel.Draw(p,d,REASON_EFFECT)
	elseif sel==2 then
		-- 获取场上所有可以回到手牌的魔法、陷阱卡
		local g=Duel.GetMatchingGroup(c91501248.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		-- 将获取到的魔法、陷阱卡全部送回持有者手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	elseif sel==3 then
		-- 获取对方场上的所有怪兽
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		-- 破坏对方场上的所有怪兽
		Duel.Destroy(g,REASON_EFFECT)
	else
		-- 获取当前连锁的目标玩家（即自己）
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		-- 获取对方的所有手牌
		local g=Duel.GetFieldGroup(p,0,LOCATION_HAND)
		if g:GetCount()>0 then
			-- 让玩家确认对方的所有手牌
			Duel.ConfirmCards(p,g)
			-- 提示玩家选择要送回卡组的卡
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			local sg=g:FilterSelect(p,Card.IsAbleToDeck,1,1,nil)
			-- 将选中的卡送回卡组并洗牌
			Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			-- 洗切对方的手牌
			Duel.ShuffleHand(1-p)
		end
	end
end
