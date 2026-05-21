--ディーラーズ・チョイス
-- 效果：
-- ①：双方玩家把卡组洗切，从卡组抽1张。那之后，双方玩家选1张手卡丢弃。
function c89462956.initial_effect(c)
	-- ①：双方玩家把卡组洗切，从卡组抽1张。那之后，双方玩家选1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c89462956.target)
	e1:SetOperation(c89462956.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的落点检测与操作信息注册
function c89462956.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方玩家是否都可以从卡组抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
	-- 设置操作信息，表示该效果包含双方玩家丢弃手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,PLAYER_ALL,1)
	-- 设置操作信息，表示该效果包含双方玩家抽卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
-- 效果处理的执行逻辑
function c89462956.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取回合玩家卡组最上方的1张卡
	local g1=Duel.GetDecktopGroup(tp,1)
	-- 获取对手卡组最上方的1张卡
	local g2=Duel.GetDecktopGroup(1-tp,1)
	if g1:GetCount()==0 or g2:GetCount()==0 then return end
	-- 洗切回合玩家的卡组
	Duel.ShuffleDeck(tp)
	-- 洗切对手的卡组
	Duel.ShuffleDeck(1-tp)
	-- 回合玩家因效果抽1张卡
	local h1=Duel.Draw(tp,1,REASON_EFFECT)
	-- 对手因效果抽1张卡
	local h2=Duel.Draw(1-tp,1,REASON_EFFECT)
	-- 若有玩家成功抽卡，则中断当前效果，使后续的丢弃手卡处理不与抽卡同时进行
	if h1>0 or h2>0 then Duel.BreakEffect() end
	if h1>0 then
		-- 洗切回合玩家的手卡
		Duel.ShuffleHand(tp)
		-- 回合玩家选择1张手卡丢弃
		Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
	end
	if h2>0 then
		-- 洗切对手的手卡
		Duel.ShuffleHand(1-tp)
		-- 对手选择1张手卡丢弃
		Duel.DiscardHand(1-tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
