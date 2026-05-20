--ファラオの審判
-- 效果：
-- 把基本分支付一半，从以下效果选择1个才能发动。
-- ●自己墓地有「友情 YU-JYO」存在的场合，直到回合结束时，对方场上的怪兽的效果无效化，对方不能把怪兽召唤·反转召唤·特殊召唤·盖放，怪兽的效果的发动不能进行并无效化。
-- ●自己墓地有「团结 UNITY」存在的场合，直到回合结束时，对方场上的魔法·陷阱卡的效果无效化，对方不能把魔法·陷阱卡发动·盖放，魔法·陷阱卡的效果的发动不能进行并无效化。
function c55948544.initial_effect(c)
	-- 把基本分支付一半，从以下效果选择1个才能发动。●自己墓地有「友情 YU-JYO」存在的场合，直到回合结束时，对方场上的怪兽的效果无效化，对方不能把怪兽召唤·反转召唤·特殊召唤·盖放，怪兽的效果的发动不能进行并无效化。●自己墓地有「团结 UNITY」存在的场合，直到回合结束时，对方场上的魔法·陷阱卡的效果无效化，对方不能把魔法·陷阱卡发动·盖放，魔法·陷阱卡的效果的发动不能进行并无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c55948544.cost)
	e1:SetTarget(c55948544.target)
	e1:SetOperation(c55948544.operation)
	c:RegisterEffect(e1)
end
-- 支付一半基本分的Cost函数。
function c55948544.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 扣除当前一半的基本分作为发动代价。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 检查墓地是否存在「友情 YU-JYO」或「团结 UNITY」并让玩家选择其中一个效果发动的Target函数。
function c55948544.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在「友情 YU-JYO」。
	local b1=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,81332143)
	-- 检查自己墓地是否存在「团结 UNITY」。
	local b2=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,14731897)
	if chk==0 then return b1 or b2 end
	-- 让玩家从满足条件的选项中选择一个效果发动。
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(55948544,0)},  --"「友情 YU-JYO」"
		{b2,aux.Stringid(55948544,1)})  --"「团结 UNITY」"
	e:SetLabel(op)
end
-- 根据玩家的选择，适用对应效果的Operation函数。
function c55948544.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	-- 如果选择了第一个效果（友情）且墓地确实存在「友情 YU-JYO」。
	if op==1 and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,81332143) then
		-- 对方不能把怪兽召唤·反转召唤·特殊召唤·盖放
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(0,1)
		-- 注册对方不能特殊召唤怪兽的效果。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_SUMMON)
		-- 注册对方不能通常召唤怪兽的效果。
		Duel.RegisterEffect(e2,tp)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
		-- 注册对方不能反转召唤怪兽的效果。
		Duel.RegisterEffect(e3,tp)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CANNOT_MSET)
		-- 注册对方不能里侧表示通常召唤（盖放）怪兽的效果。
		Duel.RegisterEffect(e4,tp)
		local e5=e1:Clone()
		e5:SetCode(EFFECT_CANNOT_TURN_SET)
		-- 注册对方不能把怪兽变更为里侧表示（盖放）的效果。
		Duel.RegisterEffect(e5,tp)
		-- 怪兽的效果的发动不能进行
		local e6=Effect.CreateEffect(c)
		e6:SetType(EFFECT_TYPE_FIELD)
		e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e6:SetCode(EFFECT_CANNOT_ACTIVATE)
		e6:SetTargetRange(0,1)
		e6:SetValue(c55948544.aclimit1)
		e6:SetReset(RESET_PHASE+PHASE_END)
		-- 注册对方不能发动怪兽效果的效果。
		Duel.RegisterEffect(e6,tp)
		-- 对方场上的怪兽的效果无效化
		local e7=Effect.CreateEffect(c)
		e7:SetType(EFFECT_TYPE_FIELD)
		e7:SetCode(EFFECT_DISABLE)
		e7:SetTargetRange(0,LOCATION_MZONE)
		e7:SetTarget(c55948544.distg1)
		e7:SetReset(RESET_PHASE+PHASE_END)
		-- 注册对方场上怪兽效果无效化的效果。
		Duel.RegisterEffect(e7,tp)
		-- 并无效化
		local e8=Effect.CreateEffect(c)
		e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e8:SetCode(EVENT_CHAIN_SOLVING)
		e8:SetCondition(c55948544.discon1)
		e8:SetOperation(c55948544.disop)
		e8:SetReset(RESET_PHASE+PHASE_END)
		-- 注册在连锁处理时使对方发动的怪兽效果无效的效果。
		Duel.RegisterEffect(e8,tp)
	end
	-- 如果选择了第二个效果（团结）且墓地确实存在「团结 UNITY」。
	if op==2 and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,14731897) then
		-- 对方不能把魔法·陷阱卡发动·盖放
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SSET)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册对方不能盖放魔法·陷阱卡的效果。
		Duel.RegisterEffect(e1,tp)
		-- 魔法·陷阱卡的效果的发动不能进行
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetTargetRange(0,1)
		e2:SetValue(c55948544.aclimit2)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 注册对方不能发动魔法·陷阱卡的效果的效果。
		Duel.RegisterEffect(e2,tp)
		-- 对方场上的魔法·陷阱卡的效果无效化
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_DISABLE)
		e3:SetTargetRange(0,LOCATION_SZONE)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 注册对方场上魔法·陷阱卡效果无效化的效果。
		Duel.RegisterEffect(e3,tp)
		-- 对方场上的魔法·陷阱卡的效果无效化
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(EFFECT_DISABLE_TRAPMONSTER)
		e4:SetTargetRange(0,LOCATION_MZONE)
		e4:SetTarget(c55948544.distg2)
		e4:SetReset(RESET_PHASE+PHASE_END)
		-- 注册对方场上陷阱怪兽效果无效化的效果。
		Duel.RegisterEffect(e4,tp)
		-- 并无效化
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_CHAIN_SOLVING)
		e5:SetCondition(c55948544.discon2)
		e5:SetOperation(c55948544.disop)
		e5:SetReset(RESET_PHASE+PHASE_END)
		-- 注册在连锁处理时使对方发动的魔法·陷阱卡效果无效的效果。
		Duel.RegisterEffect(e5,tp)
	end
end
-- 限制发动卡片类型为怪兽效果的过滤函数。
function c55948544.aclimit1(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 过滤对方场上效果怪兽的无效化目标过滤函数。
function c55948544.distg1(e,c)
	return c:IsType(TYPE_EFFECT) or c:GetOriginalType()&TYPE_EFFECT~=0
end
-- 检查是否为对方发动的怪兽效果的条件函数。
function c55948544.discon1(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and rp==1-tp
end
-- 限制发动卡片类型为魔法·陷阱效果的过滤函数。
function c55948544.aclimit2(e,re,tp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 过滤对方场上陷阱怪兽的无效化目标过滤函数。
function c55948544.distg2(e,c)
	return c:IsType(TYPE_TRAP)
end
-- 检查是否为对方发动的魔法·陷阱效果的条件函数。
function c55948544.discon2(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and rp==1-tp
end
-- 使发动的效果无效的执行函数。
function c55948544.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效该连锁的效果。
	Duel.NegateEffect(ev)
end
