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
-- 代价函数：检查并支付发动所需的800基本分，作为效果发动的代价。
function c11760174.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：在发动时确认当前玩家是否能够支付800基本分，不能则效果不能发动。
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 实际支付800基本分，扣除当前玩家的生命值。
	Duel.PayLPCost(tp,800)
end
-- 目标/发动条件函数：进行额外条件判定，通过检查标记来确保该效果在一个回合内没有重复发动。
function c11760174.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家tp是否已有标记11760174（本回合已发动过该效果），没有则返回true，允许发动。
	if chk==0 then return Duel.GetFlagEffect(tp,11760174)==0 end
end
-- 效果处理：创建一个持续到结束阶段的领域效果，使所有魔法·陷阱卡不能发动，并记录已发动标记。
function c11760174.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 到本回合结束阶段为止，所有的魔法·陷阱卡都不能发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,1)
	e1:SetValue(c11760174.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将生成的禁发效果注册给玩家tp，使该效果开始对全场生效。
	Duel.RegisterEffect(e1,tp)
	-- 为玩家tp注册标记11760174，用于记录本回合已发动过此效果，在结束阶段重置。
	Duel.RegisterFlagEffect(tp,11760174,RESET_PHASE+PHASE_END,0,1)
end
-- 判定函数：若尝试发动的效果或卡的类别包含魔法或陷阱，则返回true，表示禁止其发动。
function c11760174.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
