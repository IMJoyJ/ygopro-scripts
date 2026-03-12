--大暴落
-- 效果：
-- 对方的手卡在8张以上时发动。对方把手卡加入卡组洗切，之后抽2张卡。
function c52417194.initial_effect(c)
	-- 效果原文内容：对方的手卡在8张以上时发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetHintTiming(0,TIMING_TOHAND)
	e1:SetCondition(c52417194.condition)
	e1:SetTarget(c52417194.target)
	e1:SetOperation(c52417194.activate)
	c:RegisterEffect(e1)
end
-- 规则层面作用：检查当前玩家对手手卡数量是否大于7
function c52417194.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：判断对方手牌数量是否超过7张
	return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>7
end
-- 效果原文内容：对方把手卡加入卡组洗切，之后抽2张卡。
function c52417194.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检测目标玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(1-tp) end
	-- 规则层面作用：设置连锁效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
end
-- 规则层面作用：执行大暴落的主要效果流程
function c52417194.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁效果的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 规则层面作用：获取目标玩家的所有手牌
	local g=Duel.GetFieldGroup(p,LOCATION_HAND,0)
	-- 规则层面作用：将目标玩家的手牌送入卡组并洗切
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 规则层面作用：对目标玩家的卡组进行洗切
	Duel.ShuffleDeck(p)
	-- 规则层面作用：中断当前效果处理，避免时点冲突
	Duel.BreakEffect()
	-- 规则层面作用：让目标玩家抽2张卡
	Duel.Draw(p,2,REASON_EFFECT)
end
