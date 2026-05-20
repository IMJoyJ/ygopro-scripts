--血肉の代償
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段支付1000基本分才能发动。这个回合，自己可以进行通常召唤最多3次。
-- ②：对方战斗阶段支付500基本分才能发动。进行1只怪兽的召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含卡片发动、①效果（主要阶段增加召唤次数）和②效果（对方战斗阶段进行召唤）。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：自己主要阶段支付1000基本分才能发动。这个回合，自己可以进行通常召唤最多3次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition1)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.operation1)
	c:RegisterEffect(e1)
	-- ②：对方战斗阶段支付500基本分才能发动。进行1只怪兽的召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetCondition(s.condition2)
	e2:SetCost(s.cost2)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)
end
-- 检查是否为自己的主要阶段（主要阶段1或主要阶段2）。
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合的玩家。
	local tn=Duel.GetTurnPlayer()
	-- 获取当前的阶段。
	local ph=Duel.GetCurrentPhase()
	return tn==tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 支付1000基本分的发动代价。
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 扣除玩家1000基本分。
	Duel.PayLPCost(tp,1000)
end
-- 检查当前玩家受到的通常召唤次数限制效果，若最大召唤次数小于3则可以发动。
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=0
		-- 获取当前影响玩家通常召唤次数限制的所有效果。
		local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_SET_SUMMON_COUNT_LIMIT)}
		for _,te in ipairs(ce) do
			ct=math.max(ct,te:GetValue())
		end
		return ct<3
	end
end
-- 注册一个在回合结束前将玩家通常召唤次数上限设为3次的效果。
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己可以进行通常召唤最多3次。②：对方战斗阶段支付500基本分才能发动。进行1只怪兽的召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(3)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将修改通常召唤次数上限的效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 检查是否为对方回合的战斗阶段。
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合的玩家。
	local tn=Duel.GetTurnPlayer()
	-- 获取当前的阶段。
	local ph=Duel.GetCurrentPhase()
	return tn==1-tp and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 支付500基本分的发动代价。
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付500基本分。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 扣除玩家500基本分。
	Duel.PayLPCost(tp,500)
end
-- 过滤函数：筛选手牌或场上可以进行通常召唤的怪兽。
function s.filter(c)
	return c:IsSummonable(true,nil)
end
-- 检查手牌或场上是否有可召唤的怪兽，并注册同一连锁内防止重复计算的标记，设置召唤的操作信息。
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 计算手牌和怪兽区域中满足通常召唤条件的卡片数量。
		local ct1=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
		-- 获取当前连锁中已预定进行召唤的标记数量。
		local ct2=Duel.GetFlagEffect(tp,80604091)
		return ct1-ct2>0
	end
	-- 在当前连锁中为玩家注册一个临时标记，用于防止在同一连锁中重复选择同一张卡。
	Duel.RegisterFlagEffect(tp,80604091,RESET_CHAIN,0,1)
	-- 设置连锁的操作信息为进行1只怪兽的通常召唤。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 提示玩家选择并进行1只怪兽的通常召唤。
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择要召唤的怪兽的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让玩家从手牌或怪兽区域选择1张满足通常召唤条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 让玩家无视每回合通常召唤次数限制，对选中的怪兽进行通常召唤。
		Duel.Summon(tp,tc,true,nil)
	end
end
