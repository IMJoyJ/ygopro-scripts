--攪乱作戦
-- 效果：
-- 对方将手卡加入卡组，再从卡组抽出与原本手卡数一样数目的卡。
function c77561728.initial_effect(c)
	-- 对方将手卡加入卡组，再从卡组抽出与原本手卡数一样数目的卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_TOHAND)
	e1:SetTarget(c77561728.target)
	e1:SetOperation(c77561728.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件（Target），检查对方是否可以抽卡以及对方手牌中是否存在可以回到卡组的卡
function c77561728.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在第一阶段（chk==0）检查对方是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(1-tp)
		-- 并且检查对方手牌中是否存在至少1张可以送回卡组的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND,1,nil) end
	-- 设置连锁的操作信息，声明此效果包含将对方手牌送回卡组的操作
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_HAND)
end
-- 定义效果处理（Operation），执行将对方手牌送回卡组并洗牌，然后让对方抽出相同数量卡的操作
function c77561728.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌中的所有卡片
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()==0 then return end
	-- 将获取到的对方手牌全部送回卡组
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 洗切对方的卡组
	Duel.ShuffleDeck(1-tp)
	-- 中断效果连接，使“送回卡组”与“抽卡”不视为同时处理
	Duel.BreakEffect()
	-- 让对方抽出与原本送回卡组的手牌数量相同数量的卡
	Duel.Draw(1-tp,g:GetCount(),REASON_EFFECT)
end
