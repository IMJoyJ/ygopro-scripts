--増殖するG
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己·对方回合，把这张卡从手卡送去墓地才能发动。这个回合中，以下效果适用。
-- ●每次对方把怪兽特殊召唤，自己抽1张。
function c23434538.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：自己·对方回合，把这张卡从手卡送去墓地才能发动。这个回合中，以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23434538,0))  --"对方特殊召唤时抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,23434538)
	e1:SetCost(c23434538.cost)
	e1:SetOperation(c23434538.operation)
	c:RegisterEffect(e1)
end
-- cost函数：检查手卡的这张卡能否作为cost送去墓地，若可以则作为代价送去墓地，用于发动效果。
function c23434538.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡从手卡送去墓地，作为发动效果的cost（REASON_COST）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 发动后的处理：在当前回合注册多个持续效果，用于在对方特殊召唤怪兽时让己方抽卡，并兼容连锁处理中的情况。
function c23434538.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ●每次对方把怪兽特殊召唤，自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c23434538.drcon1)
	e1:SetOperation(c23434538.drop1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将第一个持续效果注册到当前玩家，用于在对方特殊召唤成功且不在连锁处理中时立即抽1张。
	Duel.RegisterEffect(e1,tp)
	-- ●每次对方把怪兽特殊召唤，自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c23434538.regcon)
	e2:SetOperation(c23434538.regop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将第二个持续效果注册到当前玩家，用于在连锁处理中对方特殊召唤成功时记录该次特殊召唤。
	Duel.RegisterEffect(e2,tp)
	-- ●每次对方把怪兽特殊召唤，自己抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetCondition(c23434538.drcon2)
	e3:SetOperation(c23434538.drop2)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将第三个持续效果注册到当前玩家，用于在连锁处理结束后按记录次数抽相应数量的卡。
	Duel.RegisterEffect(e3,tp)
end
-- filter过滤函数：判断特殊召唤的怪兽是否是由指定玩家（sp）进行特殊召唤的。
function c23434538.filter(c,sp)
	return c:IsSummonPlayer(sp)
end
-- drcon1条件：存在对方特殊召唤的怪兽，且当前不在连锁处理中时，满足抽卡条件。
function c23434538.drcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c23434538.filter,1,nil,1-tp)
		-- 追加判定当前不在连锁处理中，避免在连锁处理中插入抽卡，此时应走延迟处理。
		and not Duel.IsChainSolving()
end
-- drop1操作：条件满足时，效果持有者抽1张卡。
function c23434538.drop1(e,tp,eg,ep,ev,re,r,rp)
	-- 让效果持有者tp抽1张卡，抽卡原因记为效果。
	Duel.Draw(tp,1,REASON_EFFECT)
end
-- regcon条件：存在对方特殊召唤的怪兽，且当前正处于连锁处理中时，需要登记次数。
function c23434538.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c23434538.filter,1,nil,1-tp)
		-- 追加判定当前正在连锁处理中，因此不能立即抽卡，先累计特殊召唤次数。
		and Duel.IsChainSolving()
end
-- regop操作：给当前玩家注册一个临时标识，记录连锁处理中对方特殊召唤了一次。
function c23434538.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 为当前玩家tp注册标识23434538，标识数量+1，该标识在连锁处理结束时自动重置。
	Duel.RegisterFlagEffect(tp,23434538,RESET_CHAIN,0,1)
end
-- drcon2条件：存在已记录的抽卡标识（大于0），说明连锁期间发生过需要抽卡的特殊召唤。
function c23434538.drcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前玩家tp拥有的23434538标识数量是否大于0。
	return Duel.GetFlagEffect(tp,23434538)>0
end
-- drop2操作：读取记录的特殊召唤次数，清除标识，然后抽取对应数量的卡。
function c23434538.drop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取累计的特殊召唤次数，作为本次需要抽卡的数量。
	local n=Duel.GetFlagEffect(tp,23434538)
	-- 清除已累计的抽卡标识，避免下次连锁重复计数。
	Duel.ResetFlagEffect(tp,23434538)
	-- 让效果持有者tp抽n张卡，n为连锁中对方特殊召唤的次数。
	Duel.Draw(tp,n,REASON_EFFECT)
end
