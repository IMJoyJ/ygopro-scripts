--増殖するG
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己·对方回合，把这张卡从手卡送去墓地才能发动。这个回合中，以下效果适用。
-- ●每次对方把怪兽特殊召唤，自己抽1张。
function c23434538.initial_effect(c)
	-- ①：自己·对方回合，把这张卡从手卡送去墓地才能发动。这个回合中，以下效果适用。
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
-- 支付将此卡从手卡送去墓地的代价
function c23434538.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡从手卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 设置当对方特殊召唤怪兽时触发的抽卡效果
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
	-- 注册第一个效果，用于检测对方特殊召唤并触发抽卡
	Duel.RegisterEffect(e1,tp)
	-- 设置当连锁处理结束时触发的抽卡效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c23434538.regcon)
	e2:SetOperation(c23434538.regop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册第二个效果，用于记录对方特殊召唤次数
	Duel.RegisterEffect(e2,tp)
	-- 设置当连锁处理结束时触发的抽卡效果
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetCondition(c23434538.drcon2)
	e3:SetOperation(c23434538.drop2)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册第三个效果，用于在连锁结束后根据记录抽卡
	Duel.RegisterEffect(e3,tp)
end
-- 用于判断特殊召唤的怪兽是否为对方的函数
function c23434538.filter(c,sp)
	return c:IsSummonPlayer(sp)
end
-- 判断对方特殊召唤怪兽时是否不在连锁处理中
function c23434538.drcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c23434538.filter,1,nil,1-tp)
		-- 确保不在连锁处理中以避免重复触发
		and not Duel.IsChainSolving()
end
-- 执行抽卡操作
function c23434538.drop1(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家抽一张卡
	Duel.Draw(tp,1,REASON_EFFECT)
end
-- 判断对方特殊召唤怪兽时是否在连锁处理中
function c23434538.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c23434538.filter,1,nil,1-tp)
		-- 确保在连锁处理中以记录特殊召唤次数
		and Duel.IsChainSolving()
end
-- 注册一个标识效果，用于记录对方特殊召唤次数
function c23434538.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 为玩家注册一个标识效果，记录特殊召唤次数
	Duel.RegisterFlagEffect(tp,23434538,RESET_CHAIN,0,1)
end
-- 判断是否已注册标识效果
function c23434538.drcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有标识效果被注册
	return Duel.GetFlagEffect(tp,23434538)>0
end
-- 根据标识效果记录的次数进行抽卡
function c23434538.drop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取标识效果记录的特殊召唤次数
	local n=Duel.GetFlagEffect(tp,23434538)
	-- 重置标识效果
	Duel.ResetFlagEffect(tp,23434538)
	-- 根据记录的次数进行抽卡
	Duel.Draw(tp,n,REASON_EFFECT)
end
