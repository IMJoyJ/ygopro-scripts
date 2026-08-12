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
	-- 这张卡的效果发动的回合，自己不能把怪兽特殊召唤。
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
-- 记录召唤成功的标志位，用于判断是否可以发动效果。
function c45812361.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(45812361,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
end
-- 判断是否可以发动效果：必须是召唤成功后的回合，并且当前阶段是主要阶段1。
function c45812361.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否可以发动效果：必须是召唤成功后的回合，并且当前阶段是主要阶段1。
	return e:GetHandler():GetFlagEffect(45812361)~=0 and Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 设置效果的费用：检查玩家在本回合是否已经进行过特殊召唤，若未进行则可以发动；同时将自身解放作为费用。
function c45812361.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：本回合未进行过特殊召唤且自身可以被解放。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 and e:GetHandler():IsReleasable() end
	-- 将自身从场上解放作为发动费用。
	Duel.Release(e:GetHandler(),REASON_COST)
	-- 创建一个场上的效果，使玩家在本回合不能特殊召唤怪兽。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将该效果注册给玩家，使其生效至回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 设置效果的目标：准备让玩家抽2张卡。
function c45812361.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以发动效果：玩家可以抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置连锁操作信息：准备让玩家抽2张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 执行效果：让玩家抽2张卡，若抽卡失败则不继续处理；然后中断当前效果处理并跳过主要阶段1。
function c45812361.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 执行抽卡操作，让玩家抽2张卡。
	local ct=Duel.Draw(tp,2,REASON_EFFECT)
	if ct==0 then return end
	-- 中断当前效果处理，使之后的效果处理视为不同时处理。
	Duel.BreakEffect()
	-- 跳过玩家的主要阶段1，使其直接进入结束阶段。
	Duel.SkipPhase(tp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
	-- 创建一个场上的效果，使玩家在本回合不能进行战斗阶段。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该效果注册给玩家，使其生效至回合结束。
	Duel.RegisterEffect(e1,tp)
end
