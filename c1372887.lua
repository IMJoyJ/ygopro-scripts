--相乗り
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：这个回合，每次对方用抽卡以外的方法从卡组·墓地把卡加入手卡，自己从卡组抽1张。
function c1372887.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：这个回合，每次对方用抽卡以外的方法从卡组·墓地把卡加入手卡，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,1372887+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c1372887.activate)
	c:RegisterEffect(e1)
end
-- 发动后，在本回合内设置三个持续效果：①不在连锁处理中时，对方以抽卡以外方式从卡组·墓地加入手卡则自己立即抽1张；②在连锁处理中时记录触发次数；③连锁结算后按累计次数抽卡。
function c1372887.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ①：这个回合，每次对方用抽卡以外的方法从卡组·墓地把卡加入手卡，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCondition(c1372887.drcon1)
	e1:SetOperation(c1372887.drop1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将处理非连锁时抽卡的持续效果e1注册给当前玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
	-- ①：这个回合，每次对方用抽卡以外的方法从卡组·墓地把卡加入手卡，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetCondition(c1372887.regcon)
	e2:SetOperation(c1372887.regop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将记录连锁中触发次数的持续效果e2注册给当前玩家，持续到回合结束。
	Duel.RegisterEffect(e2,tp)
	-- ①：这个回合，每次对方用抽卡以外的方法从卡组·墓地把卡加入手卡，自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetCondition(c1372887.drcon2)
	e3:SetOperation(c1372887.drop2)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将连锁结算后统一抽卡的持续效果e3注册给当前玩家，持续到回合结束。
	Duel.RegisterEffect(e3,tp)
end
-- 判断一张加入手卡的卡是否满足：当前控制者为对方、不是因抽卡原因、且加入手卡前位于卡组或墓地。
function c1372887.cfilter(c,tp)
	return c:IsControler(1-tp) and not c:IsReason(REASON_DRAW) and c:IsPreviousLocation(LOCATION_DECK+LOCATION_GRAVE)
end
-- 非连锁抽卡效果的触发条件：本次加入手卡的卡中存在符合条件的卡，且当前不在连锁处理中。
function c1372887.drcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查加入手卡的卡组中是否有符合条件的卡，且当前不在连锁处理中（非连锁时立即抽1张）。
	return eg:IsExists(c1372887.cfilter,1,nil,tp) and not Duel.IsChainSolving()
end
-- 处理非连锁时的抽卡效果：展示合乘的卡片，自己抽1张卡。
function c1372887.drop1(e,tp,eg,ep,ev,re,r,rp)
	-- 播放合乘的卡片展示/提示动画。
	Duel.Hint(HINT_CARD,0,1372887)
	-- 以效果原因让自己抽1张卡。
	Duel.Draw(tp,1,REASON_EFFECT)
end
-- 连锁中计数效果的触发条件：本次加入手卡的卡中存在符合条件的卡，且当前正在连锁处理中。
function c1372887.regcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查加入手卡的卡组中是否有符合条件的卡，且当前正在连锁处理中（需要累计次数）。
	return eg:IsExists(c1372887.cfilter,1,nil,tp) and Duel.IsChainSolving()
end
-- 处理连锁中的计数效果：为当前玩家注册一个标志，记录本次符合条件的加入手卡事件。
function c1372887.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 为当前玩家注册以1372887为代码、连锁结束重置的标志，计数加1。
	Duel.RegisterFlagEffect(tp,1372887,RESET_CHAIN,0,1)
end
-- 连锁结算后抽卡效果的触发条件：当前玩家存在累积的触发标志。
function c1372887.drcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家是否拥有累积的触发标志（即本次连锁中有符合条件的事件发生）。
	return Duel.GetFlagEffect(tp,1372887)>0
end
-- 处理连锁结算后的抽卡效果：读取累计触发次数，重置标志，展示合乘，然后自己抽对应数量的卡。
function c1372887.drop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前玩家累积的触发次数。
	local ct=Duel.GetFlagEffect(tp,1372887)
	-- 重置当前玩家的触发标志，避免重复处理。
	Duel.ResetFlagEffect(tp,1372887)
	-- 播放合乘的卡片展示/提示动画。
	Duel.Hint(HINT_CARD,0,1372887)
	-- 以效果原因让自己抽ct张卡（ct为累计触发次数）。
	Duel.Draw(tp,ct,REASON_EFFECT)
end
