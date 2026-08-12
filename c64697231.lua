--ダスト・シュート
-- 效果：
-- 对方手卡是4张以上的场合才能发动。把对方手卡确认并选择1张怪兽卡，那张卡回到持有者卡组。
function c64697231.initial_effect(c)
	-- 对方手卡是4张以上的场合才能发动。把对方手卡确认并选择1张怪兽卡，那张卡回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(0,TIMING_TOHAND)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c64697231.condition)
	e1:SetTarget(c64697231.target)
	e1:SetOperation(c64697231.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：对方手卡在4张以上时才能发动
function c64697231.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手卡数量并判断是否大于3张（即4张以上）
	return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>3
end
-- 效果发动时的处理：设置效果的对象玩家
function c64697231.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为发动效果的玩家
	Duel.SetTargetPlayer(tp)
end
-- 效果处理：确认对方手卡，选择1张怪兽卡回到持有者卡组，并洗切手卡
function c64697231.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家（即发动效果的玩家）
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取对方（发动效果玩家的对手）的手卡
	local g=Duel.GetFieldGroup(p,0,LOCATION_HAND)
	if g:GetCount()>0 then
		-- 给发动效果的玩家确认对方的所有手卡
		Duel.ConfirmCards(p,g)
		local tg=g:Filter(Card.IsType,nil,TYPE_MONSTER)
		if tg:GetCount()>0 then
			-- 向发动效果的玩家发送提示信息，要求选择要返回卡组的卡
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			local sg=tg:Select(p,1,1,nil)
			-- 将选择的卡送回持有者的卡组并洗牌
			Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
		-- 洗切对方的手卡
		Duel.ShuffleHand(1-p)
	end
end
