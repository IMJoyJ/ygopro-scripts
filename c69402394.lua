--暗黒の謀略
-- 效果：
-- 双方玩家选择2张手卡丢弃，从卡组抽2张卡。对方可以丢弃1张手卡让这张卡的效果无效。
function c69402394.initial_effect(c)
	-- 双方玩家选择2张手卡丢弃，从卡组抽2张卡。对方可以丢弃1张手卡让这张卡的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES_SELF+CATEGORY_HANDES_OPPO)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c69402394.target)
	e1:SetOperation(c69402394.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的可行性检测，确认双方手卡和卡组数量是否满足发动条件，并设置抽卡操作信息
function c69402394.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自身手卡数量
		local h1=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		if e:GetHandler():IsLocation(LOCATION_HAND) then h1=h1-1 end
		-- 获取对方手卡数量
		local h2=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
		-- 获取自身卡组剩余卡片数量
		local d1=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
		-- 获取对方卡组剩余卡片数量
		local d2=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
		return h1>1 and h2>1 and d1>1 and d2>1
	end
	-- 设置操作信息为双方玩家各抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,2)
end
-- 效果处理时，首先询问对方是否丢弃1张手卡来无效此效果，若选择丢弃则无效此卡效果
function c69402394.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查该连锁是否可被无效，且对方手卡数量大于0
	if Duel.IsChainDisablable(0) and Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0
		-- 提示对方玩家是否选择丢弃1张手卡以无效该效果
		and Duel.SelectYesNo(1-tp,aux.Stringid(69402394,0)) then  --"是否要丢弃1张手卡让「暗黑的谋略」的效果无效？"
		-- 对方玩家选择并丢弃1张手卡
		Duel.DiscardHand(1-tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD,nil)
		-- 无效该卡的效果
		Duel.NegateEffect(0)
		return
	end
	-- 若任意一方手卡不足2张，则不处理后续效果
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<2 or Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)<2 then return end
	-- 提示自身玩家选择要丢弃的手卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 自身玩家选择2张手卡
	local g1=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,2,2,nil)
	-- 提示对方玩家选择要丢弃的手卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 对方玩家选择2张手卡
	local g2=Duel.SelectMatchingCard(1-tp,aux.TRUE,1-tp,LOCATION_HAND,0,2,2,nil)
	g1:Merge(g2)
	-- 将双方选中的手卡送去墓地（以丢弃的形式）
	Duel.SendtoGrave(g1,REASON_EFFECT+REASON_DISCARD)
	-- 中断效果，使丢弃手卡与抽卡不视为同时处理
	Duel.BreakEffect()
	-- 自身玩家从卡组抽2张卡
	Duel.Draw(tp,2,REASON_EFFECT)
	-- 对方玩家从卡组抽2张卡
	Duel.Draw(1-tp,2,REASON_EFFECT)
end
