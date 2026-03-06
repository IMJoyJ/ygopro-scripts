--リロード
-- 效果：
-- 将自己的全部手卡放回卡组。那之后，抽与放回卡组的卡数量相同的卡。
function c22589918.initial_effect(c)
	-- 效果原文内容：将自己的全部手卡放回卡组。那之后，抽与放回卡组的卡数量相同的卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c22589918.target)
	e1:SetOperation(c22589918.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查玩家是否可以抽卡且手牌中是否存在可送入卡组的卡。
function c22589918.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查玩家是否可以抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		-- 效果作用：检查手牌中是否存在至少一张可送入卡组的卡。
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 效果作用：设置当前连锁的目标玩家为玩家tp。
	Duel.SetTargetPlayer(tp)
	-- 效果作用：设置将要处理的卡组操作信息，目标为玩家tp的手牌。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	-- 效果作用：设置将要处理的抽卡操作信息，目标为玩家tp。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果原文内容：将自己的全部手卡放回卡组。那之后，抽与放回卡组的卡数量相同的卡。
function c22589918.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的目标玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 效果作用：获取目标玩家手牌组。
	local g=Duel.GetFieldGroup(p,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	-- 效果作用：将目标玩家的手牌全部送入卡组并洗牌。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 效果作用：洗切目标玩家的卡组。
	Duel.ShuffleDeck(p)
	-- 效果作用：中断当前效果处理流程。
	Duel.BreakEffect()
	-- 效果作用：让目标玩家抽与送入卡组的卡数量相同的卡。
	Duel.Draw(p,g:GetCount(),REASON_EFFECT)
end
