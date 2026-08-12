--手札断殺
-- 效果：
-- ①：双方玩家把2张手卡送去墓地。那之后，各自从卡组抽2张。
function c74519184.initial_effect(c)
	-- ①：双方玩家把2张手卡送去墓地。那之后，各自从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c74519184.target)
	e1:SetOperation(c74519184.activate)
	c:RegisterEffect(e1)
end
-- 效果的发动准备与可行性检测
function c74519184.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自身手卡数量
		local h1=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		if e:GetHandler():IsLocation(LOCATION_HAND) then h1=h1-1 end
		-- 获取对方手卡数量
		local h2=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
		-- 检查双方手卡是否都在2张以上，且双方是否都能抽2张卡
		return h1>1 and h2>1 and Duel.IsPlayerCanDraw(tp,2) and Duel.IsPlayerCanDraw(1-tp,2)
	end
	-- 设置效果处理信息为双方玩家抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,2)
end
-- 效果处理的执行函数
function c74519184.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自身手卡数量
	local h1=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	-- 获取对方手卡数量
	local h2=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	if h1<2 or h2<2 then return end
	-- 获取当前回合玩家
	local turnp=Duel.GetTurnPlayer()
	-- 提示回合玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,turnp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 回合玩家选择2张手卡
	local g1=Duel.SelectMatchingCard(turnp,aux.TRUE,turnp,LOCATION_HAND,0,2,2,nil)
	-- 给对方玩家确认回合玩家选择的手卡
	Duel.ConfirmCards(1-turnp,g1)
	-- 提示非回合玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,1-turnp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 非回合玩家选择2张手卡
	local g2=Duel.SelectMatchingCard(1-turnp,aux.TRUE,1-turnp,LOCATION_HAND,0,2,2,nil)
	g1:Merge(g2)
	-- 将双方选择的手卡送去墓地
	Duel.SendtoGrave(g1,REASON_EFFECT)
	-- 获取实际被送去墓地的卡片组
	local og=Duel.GetOperatedGroup()
	if og:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		-- 中断当前效果，使后续的抽卡处理与送去墓地不视为同时进行
		Duel.BreakEffect()
		-- 回合玩家从卡组抽2张卡
		Duel.Draw(turnp,2,REASON_EFFECT)
		-- 非回合玩家从卡组抽2张卡
		Duel.Draw(1-turnp,2,REASON_EFFECT)
	end
end
