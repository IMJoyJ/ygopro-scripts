--マルチャミー・フワロス
-- 效果：
-- 这张卡的效果发动的回合，自己只能有1次把这张卡以外的「欢聚友伴」怪兽的效果发动。
-- ①：自己·对方回合，自己场上没有卡存在的场合，把这张卡从手卡丢弃才能发动。这个回合中，以下效果适用。
-- ●每次对方从卡组·额外卡组把怪兽特殊召唤，自己抽1张。
-- ●结束阶段，自己手卡比对方场上的卡数量＋6张要多的场合，那个相差数量的自己手卡随机回到卡组。
local s,id,o=GetID()
-- 注册主效果，设置为诱发即时效果，可在自由时点发动，发动条件为手牌且场上无卡，消耗为丢弃自身，效果为抽卡与手卡回卡组
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
	-- 设置自定义计数器，用于限制同名卡1回合只能发动1次的效果
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
-- 判断发动条件：自己场上没有卡存在且本回合发动次数小于2
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 自己场上没有卡存在且本回合发动次数小于2
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0 and Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)<2
end
-- 设置发动代价：丢弃自身到墓地，并注册一个限制对方发动「欢聚友伴」怪兽效果的永久效果
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身丢入墓地作为发动代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
	-- ●每次对方从卡组·额外卡组把怪兽特殊召唤，自己抽1张。●结束阶段，自己手卡比对方场上的卡数量＋6张要多的场合，那个相差数量的自己手卡随机回到卡组。
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetTargetRange(1,0)
	e3:SetCondition(s.actcon)
	e3:SetValue(s.aclimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制对方发动「欢聚友伴」怪兽效果的永久效果
	Duel.RegisterEffect(e3,tp)
end
-- 过滤函数，用于判断是否为「欢聚友伴」怪兽的效果
function s.chainfilter(re,tp,cid)
	return not (re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x1b2))
end
-- 判断是否超过1次发动次数，用于限制效果发动
function s.actcon(e)
	local tp=e:GetHandlerPlayer()
	-- 超过1次发动次数时，限制对方发动「欢聚友伴」怪兽效果
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)>1
end
-- 限制对方发动「欢聚友伴」怪兽效果的函数
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x1b2)
end
-- 注册多个持续效果，分别处理对方怪兽特殊召唤抽卡、记录次数、在连锁解决时抽卡、结束阶段手卡回卡组
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 对方怪兽特殊召唤成功时触发，用于抽卡
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.drcon1)
	e1:SetOperation(s.drop1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册抽卡效果
	Duel.RegisterEffect(e1,tp)
	-- 对方怪兽特殊召唤成功时触发，用于记录次数
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.regcon)
	e2:SetOperation(s.regop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册记录次数效果
	Duel.RegisterEffect(e2,tp)
	-- 连锁解决时触发，用于根据记录次数抽卡
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetCondition(s.drcon2)
	e3:SetOperation(s.drop2)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册根据记录次数抽卡效果
	Duel.RegisterEffect(e3,tp)
	-- 结束阶段触发，用于判断手卡是否比对方场上卡数量多6张以上并执行手卡回卡组
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCountLimit(1)
	e4:SetCondition(s.tdcon)
	e4:SetOperation(s.tdop)
	e4:SetReset(RESET_PHASE+PHASE_END)
	-- 注册结束阶段手卡回卡组效果
	Duel.RegisterEffect(e4,tp)
end
-- 过滤函数，用于判断是否为从卡组或额外卡组召唤的怪兽
function s.filter(c,sp)
	return c:IsSummonPlayer(sp) and c:IsSummonLocation(LOCATION_DECK+LOCATION_EXTRA)
		and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 判断是否为对方从卡组或额外卡组特殊召唤的怪兽
function s.drcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,1-tp)
		-- 确保不是在连锁处理中触发
		and not Duel.IsChainSolving()
end
-- 执行抽卡操作
function s.drop1(e,tp,eg,ep,ev,re,r,rp)
	-- 抽一张卡
	Duel.Draw(tp,1,REASON_EFFECT)
end
-- 判断是否为对方在连锁处理中特殊召唤的怪兽
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,1-tp)
		-- 确保是在连锁处理中触发
		and Duel.IsChainSolving()
end
-- 注册记录次数效果
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 注册一个标识效果，用于记录对方怪兽特殊召唤次数
	Duel.RegisterFlagEffect(tp,id+o,RESET_CHAIN,0,1)
end
-- 判断是否已记录过对方怪兽特殊召唤次数
function s.drcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 已记录过对方怪兽特殊召唤次数
	return Duel.GetFlagEffect(tp,id+o)>0
end
-- 根据记录次数执行抽卡操作
function s.drop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取记录的次数
	local n=Duel.GetFlagEffect(tp,id+o)
	-- 重置记录次数
	Duel.ResetFlagEffect(tp,id+o)
	-- 根据记录次数抽卡
	Duel.Draw(tp,n,REASON_EFFECT)
end
-- 判断结束阶段是否满足手卡回卡组条件
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 手卡数量大于对方场上卡数量加6
	return Duel.GetFieldGroupCount(e:GetOwnerPlayer(),LOCATION_HAND,0)>Duel.GetFieldGroupCount(e:GetOwnerPlayer(),0,LOCATION_ONFIELD)+6
end
-- 执行手卡回卡组操作
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自身手牌组
	local g=Duel.GetFieldGroup(e:GetOwnerPlayer(),LOCATION_HAND,0)
	-- 计算手卡数量与对方场上卡数量差值
	local d=Duel.GetFieldGroupCount(e:GetOwnerPlayer(),LOCATION_HAND,0)-(Duel.GetFieldGroupCount(e:GetOwnerPlayer(),0,LOCATION_ONFIELD)+6)
	local sg=g:RandomSelect(e:GetOwnerPlayer(),d)
	-- 将指定数量的手卡随机送回卡组
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
