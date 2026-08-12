--暗黒界の取引
-- 效果：
-- ①：双方各自从卡组抽1张。那之后，抽卡的玩家选自身1张手卡丢弃。
function c74117290.initial_effect(c)
	-- ①：双方各自从卡组抽1张。那之后，抽卡的玩家选自身1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES_SELF+CATEGORY_HANDES_OPPO+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c74117290.target)
	e1:SetOperation(c74117290.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标确认与操作信息设置（检查双方是否能抽卡，并设置丢弃手牌和抽卡的操作信息）
function c74117290.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方玩家是否都可以从卡组抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_HANDES_OPPO,nil,0,1-tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
-- 效果处理（双方玩家各抽1张卡，之后各自洗牌并选择1张手牌丢弃）
function c74117290.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 回合玩家因效果抽1张卡，并记录实际抽卡数量
	local h1=Duel.Draw(tp,1,REASON_EFFECT)
	-- 对手玩家因效果抽1张卡，并记录实际抽卡数量
	local h2=Duel.Draw(1-tp,1,REASON_EFFECT)
	-- 如果有任意玩家成功抽卡，则中断效果处理，使后续的丢弃手牌处理与抽卡不视为同时进行（造成错时点）
	if h1>0 or h2>0 then Duel.BreakEffect() end
	if h1>0 then
		-- 洗切回合玩家的手牌
		Duel.ShuffleHand(tp)
		-- 回合玩家选择自身1张手牌因效果丢弃
		Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
	end
	if h2>0 then
		-- 洗切对手玩家的手牌
		Duel.ShuffleHand(1-tp)
		-- 对手玩家选择自身1张手牌因效果丢弃
		Duel.DiscardHand(1-tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
