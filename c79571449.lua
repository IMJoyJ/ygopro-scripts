--天使の施し
-- 效果：
-- 从卡组抽3张卡，之后从手卡选2张丢弃。
function c79571449.initial_effect(c)
	-- 从卡组抽3张卡，之后从手卡选2张丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c79571449.target)
	e1:SetOperation(c79571449.activate)
	c:RegisterEffect(e1)
end
-- 设置效果发动的检测条件、目标玩家、抽卡数量以及操作信息
function c79571449.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以因效果抽3张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,3) end
	-- 设置当前连锁的对象玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为3（抽卡张数）
	Duel.SetTargetParam(3)
	-- 设置当前连锁的操作信息为：玩家tp从卡组抽3张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,2)
end
-- 效果处理：执行抽3张卡并丢弃2张手卡的操作
function c79571449.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数（抽卡张数）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽卡，若成功抽了3张卡则继续处理
	if Duel.Draw(p,d,REASON_EFFECT)==3 then
		-- 洗切目标玩家的手卡
		Duel.ShuffleHand(p)
		-- 中断当前效果，使后续的丢弃手卡与抽卡不视为同时处理
		Duel.BreakEffect()
		-- 让目标玩家选择并因效果丢弃2张手卡
		Duel.DiscardHand(p,nil,2,2,REASON_EFFECT+REASON_DISCARD)
	end
end
