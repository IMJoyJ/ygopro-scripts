--大寒波
-- 效果：
-- 主要阶段1的开始时才能发动。直到下次的自己的抽卡阶段时，双方不能有魔法·陷阱卡的效果使用以及发动·盖放。
function c60682203.initial_effect(c)
	-- 主要阶段1的开始时才能发动。直到下次的自己的抽卡阶段时，双方不能有魔法·陷阱卡的效果使用以及发动·盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c60682203.condition)
	e1:SetOperation(c60682203.operation)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数，用于判断是否在主要阶段1的开始时
function c60682203.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1，且玩家尚未进行任何操作（即阶段开始时）
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity()
end
-- 定义效果处理函数，创建并注册限制双方发动和盖放魔陷的全局效果
function c60682203.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 直到下次的自己的抽卡阶段时，双方不能有魔法·陷阱卡的效果使用以及发动
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,1)
	e1:SetValue(c60682203.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 向全局环境注册限制魔法·陷阱卡及其效果发动的效果
	Duel.RegisterEffect(e1,tp)
	-- 以及盖放
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SSET)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	-- 设置不能盖放的效果适用于所有卡片
	e2:SetTarget(aux.TRUE)
	e2:SetReset(RESET_PHASE+PHASE_END,2)
	-- 向全局环境注册限制魔法·陷阱卡盖放的效果
	Duel.RegisterEffect(e2,tp)
end
-- 定义限制发动的过滤函数，判断发动效果的卡片是否为魔法或陷阱卡
function c60682203.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
