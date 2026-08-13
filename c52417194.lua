--大暴落
-- 效果：
-- 对方的手卡在8张以上时发动。对方把手卡加入卡组洗切，之后抽2张卡。
function c52417194.initial_effect(c)
	-- 对方的手卡在8张以上时发动。对方把手卡加入卡组洗切，之后抽2张卡。
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
-- 发动条件判断：该效果只能在对方手卡数量为8张以上时发动。
function c52417194.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以自己视角查看对方手卡数量是否大于7（即对方手卡在8张以上）。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>7
end
-- 发动时目标处理：不以卡为对象而以对方玩家为对象，并确认对方玩家可以抽卡；发动时指定对方玩家为效果对象。
function c52417194.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性判定：在效果发动的场合（chk==0）检查对方玩家是否能进行抽卡（如卡组非空且不受不能抽卡限制），若不能则不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(1-tp) end
	-- 将当前连锁的效果对象玩家设置为对方玩家（1-tp），表明本效果以对方玩家为对象。
	Duel.SetTargetPlayer(1-tp)
end
-- 效果处理：取得对方玩家及其所有手牌，将手牌全部送回卡组并洗切，之后对方抽2张卡。
function c52417194.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出效果的对象玩家（即对方玩家）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取该对象玩家的全部手卡，组成卡组对象以便整体送回卡组。
	local g=Duel.GetFieldGroup(p,LOCATION_HAND,0)
	-- 将对方所有手卡以效果原因送回卡组，使用SEQ_DECKSHUFFLE使洗牌前暂时将卡置于卡组底部并标记需要洗卡组。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 洗切对方玩家的卡组，使送回卡组的手牌随机混合。
	Duel.ShuffleDeck(p)
	-- 中断当前效果处理，让后续抽卡与前一步回卡组洗切视为不同时处理，以避免错误的时点遗漏。
	Duel.BreakEffect()
	-- 让对方玩家抽2张卡，作为效果处理的一部分（受效果抽卡限制等影响）。
	Duel.Draw(p,2,REASON_EFFECT)
end
