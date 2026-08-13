--アンティ勝負
-- 效果：
-- 双方各自选择1张手卡并展示，相互确认等级。选择等级较高卡的一方将选出的卡放回手卡，选择等级较低卡的一方受到1000点伤害，将选出的卡送去墓地。选择怪兽卡以外的卡时，等级强制计为0。双方选择的卡等级相同时，各自将选出的卡放回手卡。
function c34236961.initial_effect(c)
	-- 双方各自选择1张手卡并展示，相互确认等级。选择等级较高卡的一方将选出的卡放回手卡，选择等级较低卡的一方受到1000点伤害，将选出的卡送去墓地。选择怪兽卡以外的卡时，等级强制计为0。双方选择的卡等级相同时，各自将选出的卡放回手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c34236961.target)
	e1:SetOperation(c34236961.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的合法条件检查：确认双方手牌各有至少1张卡可供选择；若这张发动卡本身仍在自己手牌，则将其从可选手牌数中扣除，避免把正要发动离手的卡也算进去。
function c34236961.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取当前玩家tp手牌中的卡数量。
		local h1=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		if e:GetHandler():IsLocation(LOCATION_HAND) then h1=h1-1 end
		-- 获取对方玩家(1-tp)手牌中的卡数量。
		local h2=Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)
		return (h1>0 and h2>0)
	end
end
-- 效果处理：双方各选1张手卡并互相确认；根据选择的卡是否为怪兽决定等级（非怪兽按0计）；比较等级后，等级高的一方将选卡放回手牌并洗切手牌，等级低的一方受到1000点伤害并将选卡送去墓地；等级相同时双方均放回手牌并洗切。
function c34236961.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 额外保护：若任一方当前手牌数为0则直接终止处理（避免因中途手牌变化导致无法选择）。
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 or Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)==0 then return end
	-- 向当前玩家发送选择提示消息，让其选择1张手卡作为给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 当前玩家从自己的手牌中无条件选择1张卡（g1），作为本方的展示卡。
	local g1=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方玩家发送选择提示消息，让其选择1张手卡作为给当前玩家确认的卡。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 对方玩家从自己的手牌中无条件选择1张卡（g2），作为对方的展示卡。
	local g2=Duel.SelectMatchingCard(1-tp,nil,1-tp,LOCATION_HAND,0,1,1,nil)
	-- 将当前玩家选择的卡g1展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,g1)
	-- 将对方玩家选择的卡g2展示给当前玩家确认。
	Duel.ConfirmCards(tp,g2)
	local atpsl=g1:GetFirst()
	local ntpsl=g2:GetFirst()
	local atplv=atpsl:IsType(TYPE_MONSTER) and atpsl:GetLevel() or 0
	local ntplv=ntpsl:IsType(TYPE_MONSTER) and ntpsl:GetLevel() or 0
	if atplv==ntplv then
		-- 平局时：洗切当前玩家手牌，表示其选出的卡放回手卡后随机化顺序。
		Duel.ShuffleHand(tp)
		-- 平局时：洗切对方玩家手牌，表示其选出的卡放回手卡后随机化顺序。
		Duel.ShuffleHand(1-tp)
	elseif atplv>ntplv then
		-- 当前玩家选择的卡等级更高时：给予对方玩家1000点效果伤害。
		Duel.Damage(1-tp,1000,REASON_EFFECT)
		-- 当前玩家选择的卡等级更高时：将对方选择的那张卡送入墓地。
		Duel.SendtoGrave(g2,REASON_EFFECT)
		-- 当前玩家选择的卡等级更高时：洗切当前玩家手牌，表示当前玩家（等级高的一方）选出的卡放回手卡。
		Duel.ShuffleHand(tp)
	else
		-- 对方玩家选择的卡等级更高时：给予当前玩家1000点效果伤害。
		Duel.Damage(tp,1000,REASON_EFFECT)
		-- 对方玩家选择的卡等级更高时：将当前玩家选择的那张卡送入墓地。
		Duel.SendtoGrave(g1,REASON_EFFECT)
		-- 对方玩家选择的卡等级更高时：洗切对方手牌，表示对方玩家（等级高的一方）选出的卡放回手卡。
		Duel.ShuffleHand(1-tp)
	end
end
