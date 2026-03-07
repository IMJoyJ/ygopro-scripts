--サイキック・インパルス
-- 效果：
-- 把自己场上存在的1只念动力族怪兽解放发动。对方手卡全部加入卡组洗切。那之后，对方从卡组抽3张卡。
function c31328739.initial_effect(c)
	-- 效果原文：把自己场上存在的1只念动力族怪兽解放发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c31328739.cost)
	e1:SetTarget(c31328739.target)
	e1:SetOperation(c31328739.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查并选择1只自己场上的念动力族怪兽进行解放作为发动代价。
function c31328739.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查自己场上是否存在满足条件的念动力族怪兽以供解放。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,nil,RACE_PSYCHO) end
	-- 效果作用：选择1只自己场上的念动力族怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,nil,RACE_PSYCHO)
	-- 效果作用：将选中的怪兽以REASON_COST原因进行解放。
	Duel.Release(g,REASON_COST)
end
-- 效果原文：对方手卡全部加入卡组洗切。那之后，对方从卡组抽3张卡。
function c31328739.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查对方手牌数量是否大于0且对方是否可以抽3张卡。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 and Duel.IsPlayerCanDraw(1-tp,3) end
	-- 效果作用：将对方设置为该效果的目标玩家。
	Duel.SetTargetPlayer(1-tp)
end
-- 效果作用：执行效果的主要处理流程，包括将对方手牌送入卡组并洗切、再抽3张卡。
function c31328739.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的目标玩家（即对方）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 效果作用：获取目标玩家（对方）手牌组。
	local g=Duel.GetFieldGroup(p,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	-- 效果作用：将对方手牌全部送入卡组并标记需要洗牌。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 效果作用：对目标玩家（对方）的卡组进行洗切。
	Duel.ShuffleDeck(p)
	-- 效果作用：中断当前效果处理，使后续效果视为不同时处理。
	Duel.BreakEffect()
	-- 效果作用：让目标玩家（对方）从卡组抽3张卡。
	Duel.Draw(p,3,REASON_EFFECT)
end
