--ゴブリンのやりくり上手
-- 效果：
-- 从卡组抽自己墓地存在的「哥布林的经营手腕」的数量＋1的卡，选择1张手卡放回到卡组最下面。
function c9744376.initial_effect(c)
	-- 从卡组抽自己墓地存在的「哥布林的经营手腕」的数量＋1的卡，选择1张手卡放回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c9744376.target)
	e1:SetOperation(c9744376.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的目标检查与准备阶段
function c9744376.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以至少抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的对象玩家为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 获取自己墓地中「哥布林的经营手腕」的数量
	local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,9744376)
	-- 设置操作信息：抽卡，数量为墓地的「哥布林的经营手腕」数量+1
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct+1)
	-- 设置操作信息：将1张手牌送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 效果处理阶段
function c9744376.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 计算需要抽卡的数量（自己墓地的「哥布林的经营手腕」数量+1）
	local d=Duel.GetMatchingGroupCount(Card.IsCode,p,LOCATION_GRAVE,0,nil,9744376)+1
	-- 让对象玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
	-- 中断当前效果处理，使后续的“放回卡组”与“抽卡”不视为同时处理
	Duel.BreakEffect()
	-- 洗切手牌
	Duel.ShuffleHand(tp)
	-- 提示玩家选择要放回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从手牌中选择1张卡
	local g=Duel.SelectMatchingCard(p,aux.TRUE,p,LOCATION_HAND,0,1,1,nil)
	-- 将选择的手牌放回到卡组最下面
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
end
