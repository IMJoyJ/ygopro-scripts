--絶滅の定め
-- 效果：
-- ①：自己·对方的主要阶段支付2000基本分才能发动。这张卡的发动后第3次的战斗阶段结束时，双方玩家必须把各自场上的卡全部送去墓地。
function c95676943.initial_effect(c)
	-- ①：自己·对方的主要阶段支付2000基本分才能发动。这张卡的发动后第3次的战斗阶段结束时，双方玩家必须把各自场上的卡全部送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(c95676943.condition)
	e1:SetCost(c95676943.cost)
	e1:SetTarget(c95676943.target)
	e1:SetOperation(c95676943.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数：限制在自己或对方的主要阶段发动
function c95676943.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 定义发动代价函数：支付2000基本分
function c95676943.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查玩家是否能够支付2000基本分
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 扣除发动玩家2000基本分作为代价
	Duel.PayLPCost(tp,2000)
end
-- 定义效果的目标处理函数：确认是魔法卡的发动
function c95676943.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) end
end
-- 定义效果的发动处理函数：初始化回合计数器并注册一个在战斗阶段结束时触发的延迟效果
function c95676943.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:SetTurnCounter(0)
	-- 这张卡的发动后第3次的战斗阶段结束时，双方玩家必须把各自场上的卡全部送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetCountLimit(1)
	e1:SetOperation(c95676943.tgop)
	e1:SetReset(RESET_PHASE+PHASE_BATTLE,3)
	-- 将该延迟触发的效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 定义延迟效果的执行函数：每次战斗阶段结束时计数器加1，达到3次时将双方场上的卡全部送去墓地
function c95676943.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==3 then
		-- 获取双方场上的所有卡片
		local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
		-- 因规则原因将双方场上的所有卡片送去墓地
		Duel.SendtoGrave(g,REASON_RULE)
	end
end
