--機動砦のギア・ゴーレム
-- 效果：
-- 这个效果在主要阶段一才能发动。支付800基本分。本回合这张卡可以对对方进行直接攻击。
function c30190809.initial_effect(c)
	-- 这个效果在主要阶段一才能发动。支付800基本分。本回合这张卡可以对对方进行直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30190809,0))  --"直接攻击"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c30190809.condition)
	e1:SetCost(c30190809.cost)
	e1:SetOperation(c30190809.operation)
	c:RegisterEffect(e1)
end
-- 检查当前阶段是否为主要阶段一且该卡未获得直接攻击效果
function c30190809.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为主要阶段一且该卡未获得直接攻击效果
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and e:GetHandler():GetEffectCount(EFFECT_DIRECT_ATTACK)==0
end
-- 支付800基本分
function c30190809.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付800基本分
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 让玩家支付800基本分
	Duel.PayLPCost(tp,800)
end
-- 使本回合这张卡可以对对方进行直接攻击
function c30190809.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使本回合这张卡可以对对方进行直接攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
