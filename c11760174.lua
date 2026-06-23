--言語道断侍
-- 效果：
-- 支付800基本分。到本回合结束阶段为止，所有的魔法·陷阱卡都不能发动。
function c11760174.initial_effect(c)
	-- 支付800基本分。到本回合结束阶段为止，所有的魔法·陷阱卡都不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11760174,0))  --"发动限制"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c11760174.cost)
	e1:SetTarget(c11760174.target)
	e1:SetOperation(c11760174.operation)
	c:RegisterEffect(e1)
end
-- 检查是否能支付800基本分
function c11760174.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 支付800基本分
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 设置效果目标
	Duel.PayLPCost(tp,800)
end
-- 检查是否已发动过此效果
function c11760174.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动此效果时，若未发动过则可以发动
	if chk==0 then return Duel.GetFlagEffect(tp,11760174)==0 end
end
-- 发动此效果时，注册不能发动魔法·陷阱卡的效果
function c11760174.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 注册一个影响全场的不能发动效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,1)
	e1:SetValue(c11760174.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册一个标识效果，用于记录此效果已发动
	Duel.RegisterFlagEffect(tp,11760174,RESET_PHASE+PHASE_END,0,1)
end
-- 判断效果是否作用于魔法或陷阱卡
function c11760174.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
