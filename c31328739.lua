--サイキック・インパルス
-- 效果：
-- 把自己场上存在的1只念动力族怪兽解放发动。对方手卡全部加入卡组洗切。那之后，对方从卡组抽3张卡。
function c31328739.initial_effect(c)
	-- 把自己场上存在的1只念动力族怪兽解放发动。对方手卡全部加入卡组洗切。那之后，对方从卡组抽3张卡。
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
-- 代价函数：从自己场上选择并解放1只念动力族怪兽作为发动费用。
function c31328739.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认自己场上存在至少1只可解放的念动力族怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,nil,RACE_PSYCHO) end
	-- 从自己场上选择1只念动力族怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,nil,RACE_PSYCHO)
	-- 将选择的念动力族怪兽解放，作为发动代价。
	Duel.Release(g,REASON_COST)
end
-- 发动时的目标设定函数：确认对方手牌有卡且对方可以抽3张，并将效果对象玩家指定为对方。
function c31328739.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：对方手牌存在卡，且对方玩家可以抽3张卡。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 and Duel.IsPlayerCanDraw(1-tp,3) end
	-- 将当前连锁效果的对象玩家设为对方（1-tp）。
	Duel.SetTargetPlayer(1-tp)
end
-- 效果处理函数：将对方全部手牌洗回卡组，然后让对方抽3张卡。
function c31328739.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得效果对象玩家（对方）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 取得对象玩家手牌区的全部卡。
	local g=Duel.GetFieldGroup(p,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	-- 将对方手牌全部弹回其持有者卡组，并标记需要洗切。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 洗切对方卡组。
	Duel.ShuffleDeck(p)
	-- 中断效果处理，使后续抽卡与之前的回卡组处理视为不同时处理。
	Duel.BreakEffect()
	-- 对方玩家抽3张卡。
	Duel.Draw(p,3,REASON_EFFECT)
end
