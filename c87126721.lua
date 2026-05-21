--マルチャミー・ニャルス
-- 效果：
-- 这张卡的效果发动的回合，自己只能有1次把这张卡以外的「欢聚友伴」怪兽的效果发动。
-- ①：自己·对方回合，自己场上没有卡存在的场合，把这张卡从手卡丢弃才能发动。这个回合中，以下效果适用。
-- ●每次对方把墓地·除外状态的怪兽特殊召唤，自己抽1张。
-- ●结束阶段，自己手卡比对方场上的卡数量＋6张要多的场合，那个相差数量的自己手卡随机回到卡组。
local s,id,o=GetID()
-- 注册卡片初始效果，包括手牌发动的效果和用于限制「欢聚友伴」怪兽效果发动次数的自定义计数器。
function s.initial_effect(c)
	-- ①：自己·对方回合，自己场上没有卡存在的场合，把这张卡从手卡丢弃才能发动。这个回合中，以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"抽卡&手卡回卡组"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.drcon)
	e1:SetCost(s.drcost)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	-- 注册自定义活动计数器，用于记录本回合玩家发动「欢聚友伴」怪兽效果的次数。
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
-- 手牌效果发动的条件判定函数（自己场上没有卡存在，且本回合发动「欢聚友伴」怪兽效果的次数在限制范围内）。
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自己场上没有卡存在，且本回合自己发动「欢聚友伴」怪兽效果的次数小于2次（即除这张卡外最多只能再发动1次）。
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0 and Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)<2
end
-- 手牌效果发动的代价与誓约限制处理函数（丢弃自身，并注册本回合「欢聚友伴」怪兽效果发动次数的限制效果）。
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将手牌中的这张卡丢弃送去墓地作为发动代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
	-- 这张卡的效果发动的回合，自己只能有1次把这张卡以外的「欢聚友伴」怪兽的效果发动。
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetTargetRange(1,0)
	e3:SetCondition(s.actcon)
	e3:SetValue(s.aclimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果，限制玩家本回合发动「欢聚友伴」怪兽效果的次数。
	Duel.RegisterEffect(e3,tp)
end
-- 计数器过滤函数，用于筛选出非「欢聚友伴」怪兽效果的发动（即对「欢聚友伴」怪兽效果的发动进行计数）。
function s.chainfilter(re,tp,cid)
	return not (re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x1b2))
end
-- 限制发动效果的条件判定函数（当本回合发动「欢聚友伴」怪兽效果的次数超过1次时适用）。
function s.actcon(e)
	local tp=e:GetHandlerPlayer()
	-- 判定本回合自己发动「欢聚友伴」怪兽效果的次数是否已经超过1次。
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)>1
end
-- 限制发动的效果类型判定函数（限制「欢聚友伴」怪兽效果的发动）。
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x1b2)
end
-- 手牌效果处理函数，注册本回合适用的抽卡效果（非连锁中和连锁解决时）以及结束阶段手卡回卡组的效果。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ●每次对方把墓地·除外状态的怪兽特殊召唤，自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.drcon1)
	e1:SetOperation(s.drop1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册在非连锁解决时对方特殊召唤成功即时抽卡的效果。
	Duel.RegisterEffect(e1,tp)
	-- ●每次对方把墓地·除外状态的怪兽特殊召唤，自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.regcon)
	e2:SetOperation(s.regop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册在连锁解决中对方特殊召唤成功时，用于记录抽卡张数的标记效果。
	Duel.RegisterEffect(e2,tp)
	-- ●每次对方把墓地·除外状态的怪兽特殊召唤，自己抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetCondition(s.drcon2)
	e3:SetOperation(s.drop2)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册在连锁解决完毕后，根据之前记录的标记张数进行抽卡的效果。
	Duel.RegisterEffect(e3,tp)
	-- ●结束阶段，自己手卡比对方场上的卡数量＋6张要多的场合，那个相差数量的自己手卡随机回到卡组。
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCountLimit(1)
	e4:SetCondition(s.tdcon)
	e4:SetOperation(s.tdop)
	e4:SetReset(RESET_PHASE+PHASE_END)
	-- 注册在结束阶段适用的手卡随机回到卡组的效果。
	Duel.RegisterEffect(e4,tp)
end
-- 过滤函数，用于筛选由对方从墓地或除外状态特殊召唤的怪兽。
function s.filter(c,sp)
	return c:IsSummonPlayer(sp) and c:IsSummonLocation(LOCATION_GRAVE+LOCATION_REMOVED)
		and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 非连锁解决时抽卡效果的触发条件判定（对方从墓地或除外状态特殊召唤了怪兽，且当前不在连锁解决中）。
function s.drcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,1-tp)
		-- 判定当前是否不处于连锁解决过程中（避免在连锁中直接抽卡导致时点错误）。
		and not Duel.IsChainSolving()
end
-- 非连锁解决时的抽卡效果处理函数。
function s.drop1(e,tp,eg,ep,ev,re,r,rp)
	-- 玩家因效果抽1张卡。
	Duel.Draw(tp,1,REASON_EFFECT)
end
-- 连锁解决中特殊召唤时注册标记的条件判定（对方从墓地或除外状态特殊召唤了怪兽，且当前正在连锁解决中）。
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,1-tp)
		-- 判定当前是否处于连锁解决过程中。
		and Duel.IsChainSolving()
end
-- 连锁解决中特殊召唤时的标记处理函数。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 为玩家注册一个在连锁结束时重置的标记效果，用于记录需要抽卡的张数。
	Duel.RegisterFlagEffect(tp,id+o,RESET_CHAIN,0,1)
end
-- 连锁解决完毕后抽卡效果的触发条件判定（存在需要抽卡的标记）。
function s.drcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判定玩家身上是否存在需要抽卡的标记。
	return Duel.GetFlagEffect(tp,id+o)>0
end
-- 连锁解决完毕后的抽卡效果处理函数。
function s.drop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家身上注册的标记数量（即需要抽卡的张数）。
	local n=Duel.GetFlagEffect(tp,id+o)
	-- 重置（清除）玩家身上的抽卡标记。
	Duel.ResetFlagEffect(tp,id+o)
	-- 玩家因效果抽取与标记数量相同张数的卡。
	Duel.Draw(tp,n,REASON_EFFECT)
end
-- 结束阶段手卡回卡组效果的触发条件判定（自己手卡数量大于对方场上卡数量+6）。
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自己手卡数量是否大于对方场上的卡数量＋6张。
	return Duel.GetFieldGroupCount(e:GetOwnerPlayer(),LOCATION_HAND,0)>Duel.GetFieldGroupCount(e:GetOwnerPlayer(),0,LOCATION_ONFIELD)+6
end
-- 结束阶段手卡回卡组效果的处理函数。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己手牌中的所有卡片。
	local g=Duel.GetFieldGroup(e:GetOwnerPlayer(),LOCATION_HAND,0)
	-- 计算自己手卡数量与（对方场上卡数量＋6）的相差数量。
	local d=Duel.GetFieldGroupCount(e:GetOwnerPlayer(),LOCATION_HAND,0)-(Duel.GetFieldGroupCount(e:GetOwnerPlayer(),0,LOCATION_ONFIELD)+6)
	local sg=g:RandomSelect(e:GetOwnerPlayer(),d)
	-- 将随机选出的相差数量的手牌送回持有者卡组并洗牌。
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
