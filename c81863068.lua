--悪魔の偵察者
-- 效果：
-- 反转：对方从卡组抽3张卡。这个效果抽到的卡给双方确认，从那之中把魔法卡全部丢弃去墓地。
function c81863068.initial_effect(c)
	-- 反转：对方从卡组抽3张卡。这个效果抽到的卡给双方确认，从那之中把魔法卡全部丢弃去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81863068,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c81863068.target)
	e1:SetOperation(c81863068.operation)
	c:RegisterEffect(e1)
end
-- 设置效果发动的目标，确定抽卡玩家为对方以及抽卡数量为3张
function c81863068.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的对象参数为3（抽卡张数）
	Duel.SetTargetParam(3)
	-- 设置当前连锁的操作信息为对方玩家抽3张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,3)
end
-- 效果处理，执行对方抽卡、双方确认并丢弃其中魔法卡的操作
function c81863068.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家和对象参数（抽卡张数）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽卡，若实际抽卡张数为0则结束处理
	if Duel.Draw(p,d,REASON_EFFECT)==0 then return end
	-- 中断当前效果，使后续的确认和丢弃处理与抽卡不视为同时进行
	Duel.BreakEffect()
	-- 获取刚才因抽卡操作实际加入手卡的卡片组
	local g=Duel.GetOperatedGroup()
	-- 给己方玩家确认对方抽到的卡片组，实现双方确认
	Duel.ConfirmCards(1-p,g)
	local dg=g:Filter(Card.IsType,nil,TYPE_SPELL)
	-- 将筛选出的魔法卡因效果丢弃去墓地
	Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
	-- 对方玩家洗切手卡
	Duel.ShuffleHand(p)
end
