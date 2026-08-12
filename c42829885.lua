--強引な番兵
-- 效果：
-- 把对方手卡确认，从那之中选1张卡回到卡组。
function c42829885.initial_effect(c)
	-- 创建效果，设置效果类别为回卡组，类型为发动效果，具有以玩家为对象的特性，触发时点为自由时点，设置目标函数和发动函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c42829885.target)
	e1:SetOperation(c42829885.activate)
	c:RegisterEffect(e1)
end
-- 效果的发动条件判断，检查对方手牌数量是否大于0
function c42829885.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断效果是否满足发动条件，即对方手牌数量大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 设置当前效果的目标玩家为玩家tp
	Duel.SetTargetPlayer(tp)
	-- 设置当前效果的操作信息，指定将对方手牌送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,1-tp,LOCATION_HAND)
end
-- 效果发动时执行的操作，获取目标玩家并检索其手牌，确认手牌后选择一张送回卡组并洗切对方手牌
function c42829885.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取目标玩家的手牌组
	local g=Duel.GetFieldGroup(p,0,LOCATION_HAND)
	if g:GetCount()>0 then
		-- 确认目标玩家的手牌
		Duel.ConfirmCards(p,g)
		-- 提示目标玩家选择要送回卡组的卡
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=g:Select(p,1,1,nil)
		-- 将选择的卡送回卡组并洗牌
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 洗切目标玩家的手牌
		Duel.ShuffleHand(1-p)
	end
end
