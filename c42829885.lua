--強引な番兵
-- 效果：
-- 把对方手卡确认，从那之中选1张卡回到卡组。
function c42829885.initial_effect(c)
	-- 把对方手卡确认，从那之中选1张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c42829885.target)
	e1:SetOperation(c42829885.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标处理：检查对方手牌是否存在卡，将发动者设为对象玩家，并设置“回卡组”的操作信息。
function c42829885.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手牌是否存在至少1张卡，作为效果能否发动的条件（chk==0时返回是否满足）。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 将当前连锁的对象玩家设为发动者tp，以便效果处理时从发动者视角获取对方手牌。
	Duel.SetTargetPlayer(tp)
	-- 设置操作信息：效果分类为回卡组，预计处理发动者对方的手牌（数量在处理时确定，不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,1-tp,LOCATION_HAND)
end
-- 效果处理：确认对方手牌，让发动者选择其中1张返回持有者卡组，并洗切对方手牌。
function c42829885.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出发动时设定的对象玩家（即发动者tp）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取以对象玩家p为视角的对方的手牌，即发动者对方的手牌集合。
	local g=Duel.GetFieldGroup(p,0,LOCATION_HAND)
	if g:GetCount()>0 then
		-- 向对象玩家p展示（确认）其对方的手牌，对应“把对方手卡确认”。
		Duel.ConfirmCards(p,g)
		-- 给对象玩家p显示选择提示：“请选择要返回卡组的卡”。
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=g:Select(p,1,1,nil)
		-- 将选择的卡以效果原因返回其持有者卡组，使用SEQ_DECKSHUFFLE表示回卡组后需要洗牌。
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 洗切对方（1-p）的手牌，以隐藏之前确认过的手牌顺序。
		Duel.ShuffleHand(1-p)
	end
end
