--マルチャミー・プルリア
-- 效果：
-- 这张卡的效果发动的回合，自己只能有1次把这张卡以外的「欢聚友伴」怪兽的效果发动。
-- ①：自己·对方回合，自己场上没有卡存在的场合，把这张卡从手卡丢弃才能发动。这个回合中，以下效果适用。
-- ●每次对方从手卡把怪兽召唤·特殊召唤，自己抽1张。
-- ●结束阶段，自己手卡比对方场上的卡数量＋6张要多的场合，那个相差数量的自己手卡随机回到卡组。
local s,id,o=GetID()
-- 注册卡片初始效果，并设置用于限制「欢聚友伴」怪兽效果发动次数的自定义活动计数器。
function s.initial_effect(c)
	aux.EnableMulcharmyGlobalCheck()
	--draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.drcon)
	e1:SetCost(s.drcost)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
end
-- 检查发动条件：自己场上没有卡存在，且本回合自己发动「欢聚友伴」怪兽效果的次数小于2次。
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0 and Duel.GetFlagEffect(tp,84192580)<=1
end
-- 丢弃自身作为发动代价，并注册一个限制本回合只能再发动1次其他「欢聚友伴」怪兽效果的誓约效果。
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡从手卡丢弃送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 效果处理：注册在对方从手卡召唤·特殊召唤怪兽时让自己抽卡的多个延迟/即时触发效果，以及在结束阶段将多余手卡随机回到卡组的效果。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ●每次对方从手卡把怪兽召唤·特殊召唤，自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.drcon1)
	e1:SetOperation(s.drop1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册在对方从手卡特殊召唤怪兽成功时（非连锁处理中）让自己抽卡的效果。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	-- 注册在对方从手卡通常召唤怪兽成功时（非连锁处理中）让自己抽卡的效果。
	Duel.RegisterEffect(e2,tp)
	-- ●每次对方从手卡把怪兽召唤·特殊召唤，自己抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(s.regcon)
	e3:SetOperation(s.regop)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册在连锁处理中对方从手卡特殊召唤怪兽时，用于记录抽卡张数的标记效果。
	Duel.RegisterEffect(e3,tp)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	-- 注册在连锁处理中对方从手卡通常召唤怪兽时，用于记录抽卡张数的标记效果。
	Duel.RegisterEffect(e4,tp)
	-- ●每次对方从手卡把怪兽召唤·特殊召唤，自己抽1张。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetCode(EVENT_CHAIN_SOLVED)
	e5:SetCondition(s.drcon2)
	e5:SetOperation(s.drop2)
	e5:SetReset(RESET_PHASE+PHASE_END)
	-- 注册在连锁处理完毕后，根据之前记录的标记效果数量让玩家抽对应张数卡的效果。
	Duel.RegisterEffect(e5,tp)
	-- ●结束阶段，自己手卡比对方场上的卡数量＋6张要多的场合，那个相差数量的自己手卡随机回到卡组。
	local e6=Effect.CreateEffect(e:GetHandler())
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetCountLimit(1)
	e6:SetCondition(s.tdcon)
	e6:SetOperation(s.tdop)
	e6:SetReset(RESET_PHASE+PHASE_END)
	-- 注册在结束阶段将多余手卡随机回到卡组的效果。
	Duel.RegisterEffect(e6,tp)
end
-- 过滤条件：由指定玩家从手卡召唤或特殊召唤的怪兽。
function s.filter(c,sp)
	return c:IsSummonPlayer(sp) and c:IsSummonLocation(LOCATION_HAND)
end
-- 抽卡效果1的触发条件：对方从手卡召唤·特殊召唤了怪兽，且当前不处于连锁处理中。
function s.drcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,1-tp)
		-- 且当前不处于连锁处理中。
		and not Duel.IsChainSolving()
end
-- 抽卡效果1的处理：自己抽1张卡。
function s.drop1(e,tp,eg,ep,ev,re,r,rp)
	-- 玩家因效果抽1张卡。
	Duel.Draw(tp,1,REASON_EFFECT)
end
-- 标记效果的触发条件：对方从手卡召唤·特殊召唤了怪兽，且当前正处于连锁处理中。
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,1-tp)
		-- 且当前正处于连锁处理中。
		and Duel.IsChainSolving()
end
-- 标记效果的处理：给玩家注册一个用于记录抽卡张数的Flag效果。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家注册一个在连锁结束时重置的Flag效果，用于累计在连锁中需要抽卡的张数。
	Duel.RegisterFlagEffect(tp,id+o,RESET_CHAIN,0,1)
end
-- 连锁后抽卡效果的触发条件：存在已记录的抽卡Flag效果。
function s.drcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家是否拥有至少1个用于记录抽卡张数的Flag效果。
	return Duel.GetFlagEffect(tp,id+o)>0
end
-- 连锁后抽卡效果的处理：获取Flag数量，重置Flag，并让玩家抽取对应数量的卡。
function s.drop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家当前拥有的抽卡Flag效果数量（即需要抽卡的张数）。
	local n=Duel.GetFlagEffect(tp,id+o)
	-- 重置（清除）玩家的抽卡Flag效果。
	Duel.ResetFlagEffect(tp,id+o)
	-- 玩家因效果抽取累计的n张卡。
	Duel.Draw(tp,n,REASON_EFFECT)
end
-- 回卡组效果的触发条件：自己手卡数量大于对方场上的卡数量＋6张。
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己手卡数量是否大于对方场上的卡数量＋6张。
	return Duel.GetFieldGroupCount(e:GetOwnerPlayer(),LOCATION_HAND,0)>Duel.GetFieldGroupCount(e:GetOwnerPlayer(),0,LOCATION_ONFIELD)+6
end
-- 回卡组效果的处理：计算相差数量，随机选择对应数量的自己手卡，并将其洗回卡组。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己手卡的所有卡片组。
	local g=Duel.GetFieldGroup(e:GetOwnerPlayer(),LOCATION_HAND,0)
	-- 计算自己手卡数量与（对方场上的卡数量＋6）之间的相差数量。
	local d=Duel.GetFieldGroupCount(e:GetOwnerPlayer(),LOCATION_HAND,0)-(Duel.GetFieldGroupCount(e:GetOwnerPlayer(),0,LOCATION_ONFIELD)+6)
	local sg=g:RandomSelect(e:GetOwnerPlayer(),d)
	-- 将随机选出的相差数量的手卡洗回持有者的卡组。
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
