--儚無みずき
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己·对方回合，把这张卡从手卡丢弃才能发动。这个回合中，以下效果适用。
-- ●每次对方在主要阶段以及战斗阶段把效果怪兽特殊召唤，自己回复那些怪兽的攻击力数值的基本分。这个效果没让自己基本分回复的场合，结束阶段让自己基本分变成一半。
function c60643553.initial_effect(c)
	-- ①：自己·对方回合，把这张卡从手卡丢弃才能发动。这个回合中，以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60643553,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,60643553)
	e1:SetCondition(c60643553.condition)
	e1:SetCost(c60643553.cost)
	e1:SetOperation(c60643553.operation)
	c:RegisterEffect(e1)
end
-- 判断是否满足发动条件：当前阶段不是结束阶段
function c60643553.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前阶段是否不等于结束阶段
	return Duel.GetCurrentPhase()~=PHASE_END
end
-- 发动代价：把这张卡从手卡丢弃
function c60643553.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身作为发动代价丢弃送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 发动效果：注册在不同时点触发的回复基本分效果以及结束阶段基本分减半的效果
function c60643553.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ●每次对方在主要阶段以及战斗阶段把效果怪兽特殊召唤，自己回复那些怪兽的攻击力数值的基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c60643553.lpcon1)
	e1:SetOperation(c60643553.lpop1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册非连锁处理中特殊召唤时回复基本分的全局效果
	Duel.RegisterEffect(e1,tp)
	-- ●每次对方在主要阶段以及战斗阶段把效果怪兽特殊召唤，自己回复那些怪兽的攻击力数值的基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c60643553.regcon)
	e2:SetOperation(c60643553.regop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册连锁处理中特殊召唤时记录怪兽的全局效果
	Duel.RegisterEffect(e2,tp)
	-- ●每次对方在主要阶段以及战斗阶段把效果怪兽特殊召唤，自己回复那些怪兽的攻击力数值的基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetCondition(c60643553.lpcon2)
	e3:SetOperation(c60643553.lpop2)
	e3:SetLabelObject(e2)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册连锁处理完毕时根据记录怪兽回复基本分的全局效果
	Duel.RegisterEffect(e3,tp)
	-- ●这个效果没让自己基本分回复的场合，结束阶段让自己基本分变成一半。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCountLimit(1)
	e4:SetCondition(c60643553.damcon)
	e4:SetOperation(c60643553.damop)
	e4:SetReset(RESET_PHASE+PHASE_END)
	-- 注册结束阶段使基本分变成一半的全局效果
	Duel.RegisterEffect(e4,tp)
end
-- 过滤条件：对方场上表侧表示的效果怪兽
function c60643553.cfilter(c,sp)
	return c:IsType(TYPE_EFFECT)
		and c:IsSummonPlayer(sp) and c:IsFaceup()
end
-- 非连锁处理中特殊召唤时回复基本分的触发条件：对方在主要阶段或战斗阶段特殊召唤了效果怪兽，且当前不在连锁处理中
function c60643553.lpcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return eg:IsExists(c60643553.cfilter,1,nil,1-tp)
		and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE))
		-- 并且当前不在连锁处理中
		and not Duel.IsChainSolving()
end
-- 非连锁处理中特殊召唤时回复基本分的处理：计算特殊召唤怪兽的攻击力总和并回复，若成功回复则注册已回复标记
function c60643553.lpop1(e,tp,eg,ep,ev,re,r,rp)
	local lg=eg:Filter(c60643553.cfilter,nil,1-tp)
	local rnum=lg:GetSum(Card.GetAttack)
	-- 回复特殊召唤怪兽的攻击力数值的基本分，若未成功回复则结束处理
	if Duel.Recover(tp,rnum,REASON_EFFECT)<1 then return end
	-- 为玩家注册已回复基本分的全局标记，持续到回合结束
	Duel.RegisterFlagEffect(tp,60643553,RESET_PHASE+PHASE_END,0,1)
end
-- 连锁处理中特殊召唤时记录怪兽的触发条件：对方在主要阶段或战斗阶段特殊召唤了效果怪兽，且当前正在连锁处理中
function c60643553.regcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return eg:IsExists(c60643553.cfilter,1,nil,1-tp)
		and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE))
		-- 并且当前正在连锁处理中
		and Duel.IsChainSolving()
end
-- 连锁处理中特殊召唤时记录怪兽的处理：将特殊召唤的怪兽保存到效果的标签对象中，并注册连锁中发生特殊召唤的标记
function c60643553.regop(e,tp,eg,ep,ev,re,r,rp)
	local lg=eg:Filter(c60643553.cfilter,nil,1-tp)
	local g=e:GetLabelObject()
	if g==nil or #g==0 then
		lg:KeepAlive()
		e:SetLabelObject(lg)
	else
		g:Merge(lg)
	end
	-- 为玩家注册连锁中发生特殊召唤的标记，在连锁结束时重置
	Duel.RegisterFlagEffect(tp,60643554,RESET_CHAIN,0,1)
end
-- 连锁处理完毕时回复基本分的触发条件：存在连锁中发生特殊召唤的标记
function c60643553.lpcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家是否存在连锁中发生特殊召唤的标记
	return Duel.GetFlagEffect(tp,60643554)>0
end
-- 连锁处理完毕时回复基本分的处理：重置标记，计算仍存在于怪兽区域的被记录怪兽的攻击力总和并回复，若成功回复则注册已回复标记
function c60643553.lpop2(e,tp,eg,ep,ev,re,r,rp)
	-- 手动重置玩家的连锁中发生特殊召唤的标记
	Duel.ResetFlagEffect(tp,60643554)
	local lg=e:GetLabelObject():GetLabelObject()
	lg=lg:Filter(Card.IsLocation,nil,LOCATION_MZONE)
	local rnum=lg:GetSum(Card.GetAttack)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e:GetLabelObject():SetLabelObject(g)
	lg:DeleteGroup()
	-- 回复被记录怪兽的攻击力数值的基本分，若未成功回复则结束处理
	if Duel.Recover(tp,rnum,REASON_EFFECT)<1 then return end
	-- 为玩家注册已回复基本分的全局标记，持续到回合结束
	Duel.RegisterFlagEffect(tp,60643553,RESET_PHASE+PHASE_END,0,1)
end
-- 结束阶段基本分减半的触发条件：本回合没有通过此效果回复过基本分
function c60643553.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家本回合是否未注册过已回复基本分的全局标记
	return Duel.GetFlagEffect(tp,60643553)<1
end
-- 结束阶段基本分减半的处理：将自身基本分变成一半（向上取整）
function c60643553.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 将玩家的当前基本分设置为当前基本分的一半（向上取整）
	return Duel.SetLP(tp,math.ceil(Duel.GetLP(tp)/2))
end
