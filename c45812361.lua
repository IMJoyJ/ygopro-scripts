--カードカー・D
-- 效果：
-- 这张卡不能特殊召唤。这张卡的效果发动的回合，自己不能把怪兽特殊召唤。
-- ①：这张卡召唤的自己主要阶段1把这张卡解放才能发动。自己抽2张。那之后，变成这个回合的结束阶段。
function c45812361.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这张卡召唤的
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(c45812361.sumsuc)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤的自己主要阶段1把这张卡解放才能发动。自己抽2张。那之后，变成这个回合的结束阶段。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(45812361,0))  --"抽卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c45812361.condition)
	e3:SetCost(c45812361.cost)
	e3:SetTarget(c45812361.target)
	e3:SetOperation(c45812361.operation)
	c:RegisterEffect(e3)
end
-- 这张卡召唤成功时，给自身设置一个“本回合召唤成功”的标记，用于后续①的发动判定；该标记在回合结束或卡牌离开/更换场所时清除。
function c45812361.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(45812361,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
end
-- 判定①的发动条件：这张卡在本回合召唤成功过，且当前处于自己的主要阶段1。
function c45812361.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 持有召唤成功标记且当前阶段为主要阶段1。
	return e:GetHandler():GetFlagEffect(45812361)~=0 and Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 支付①的发动代价：先确认本回合未进行过特殊召唤且此卡可解放，然后解放此卡，并给自己附加本回合不能特殊召唤怪兽的誓约限制。
function c45812361.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认本回合自己未进行过特殊召唤，且这张卡可以被解放，作为代价支付是否可行的检查。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 and e:GetHandler():IsReleasable() end
	-- 解放这张卡，作为发动效果的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
	-- 这张卡的效果发动的回合，自己不能把怪兽特殊召唤。自己抽2张。那之后，变成这个回合的结束阶段。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将“本回合不能特殊召唤怪兽”的誓约效果注册给发动玩家（tp），持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 设置①的发动目标要求：确认玩家可以抽2张卡，并登记为抽卡效果的操作信息。
function c45812361.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认：当前玩家可以抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 登记本连锁将执行“抽2张卡”的操作信息，供其他卡效果进行连锁判断。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 执行①的效果：抽2张卡；若抽卡成功，则中断效果处理，跳过主要阶段1，并附加不能进入战斗阶段的限制，从而直接进入结束阶段。
function c45812361.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因让当前玩家抽2张卡，返回实际抽到的数量。
	local ct=Duel.Draw(tp,2,REASON_EFFECT)
	if ct==0 then return end
	-- 中断当前效果链的处理，使后续的跳阶段处理不在同一时点进行，避免相关卡牌错失时点。
	Duel.BreakEffect()
	-- 跳过玩家本回合的主要阶段1，使流程推进到结束阶段（需配合禁止战斗阶段效果）。
	Duel.SkipPhase(tp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
	-- 那之后，变成这个回合的结束阶段。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能进入战斗阶段”的限制效果注册给当前玩家，持续到回合结束，确保跳过主要阶段1后不会进入战斗阶段而直接进入结束阶段。
	Duel.RegisterEffect(e1,tp)
end
