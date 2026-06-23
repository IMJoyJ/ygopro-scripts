--相乗り
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：这个回合，每次对方用抽卡以外的方法从卡组·墓地把卡加入手卡，自己从卡组抽1张。
function c1372887.initial_effect(c)
	-- ①：这个回合，每次对方用抽卡以外的方法从卡组·墓地把卡加入手卡，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,1372887+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c1372887.activate)
	c:RegisterEffect(e1)
end
-- 发动时的处理函数
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
	-- 注册效果e1给玩家tp
	Duel.RegisterEffect(e1,tp)
	-- ①：这个回合，每次对方用抽卡以外的方法从卡组·墓地把卡加入手卡，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetCondition(c1372887.regcon)
	e2:SetOperation(c1372887.regop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果e2给玩家tp
	Duel.RegisterEffect(e2,tp)
	-- ①：这个回合，每次对方用抽卡以外的方法从卡组·墓地把卡加入手卡，自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetCondition(c1372887.drcon2)
	e3:SetOperation(c1372887.drop2)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果e3给玩家tp
	Duel.RegisterEffect(e3,tp)
end
-- 判断目标卡是否满足条件的过滤器函数
function c1372887.cfilter(c,tp)
	return c:IsControler(1-tp) and not c:IsReason(REASON_DRAW) and c:IsPreviousLocation(LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果①的触发条件函数
function c1372887.drcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 当有满足条件的卡加入手牌且当前不在连锁处理中时触发
	return eg:IsExists(c1372887.cfilter,1,nil,tp) and not Duel.IsChainSolving()
end
-- 效果①的处理函数
function c1372887.drop1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动了合乘
	Duel.Hint(HINT_CARD,0,1372887)
	-- 玩家tp从卡组抽1张卡
	Duel.Draw(tp,1,REASON_EFFECT)
end
-- 记录连锁处理中加入手牌的条件函数
function c1372887.regcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当有满足条件的卡加入手牌且当前正在连锁处理中时触发
	return eg:IsExists(c1372887.cfilter,1,nil,tp) and Duel.IsChainSolving()
end
-- 记录连锁处理中加入手牌的处理函数
function c1372887.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 为玩家tp注册标识效果，用于记录连锁处理中加入手牌次数
	Duel.RegisterFlagEffect(tp,1372887,RESET_CHAIN,0,1)
end
-- 效果①的最终处理条件函数
function c1372887.drcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 当玩家tp拥有标识效果时触发
	return Duel.GetFlagEffect(tp,1372887)>0
end
-- 效果①的最终处理函数
function c1372887.drop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家tp的标识效果数量
	local ct=Duel.GetFlagEffect(tp,1372887)
	-- 重置玩家tp的标识效果
	Duel.ResetFlagEffect(tp,1372887)
	-- 提示发动了合乘
	Duel.Hint(HINT_CARD,0,1372887)
	-- 玩家tp从卡组抽ct张卡
	Duel.Draw(tp,ct,REASON_EFFECT)
end
