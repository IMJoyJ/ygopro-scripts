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
-- 发动条件判定：仅在主要阶段一且自身尚无直接攻击效果时才能发动本效果。
function c30190809.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回布尔值：当前为主要阶段一，且这张卡尚未拥有直接攻击效果。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and e:GetHandler():GetEffectCount(EFFECT_DIRECT_ATTACK)==0
end
-- 发动代价处理：需要支付800基本分作为发动本效果的费用。
function c30190809.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认玩家能否支付800基本分；若不能则无法发动。
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 实际支付800基本分，从玩家LP中扣除。
	Duel.PayLPCost(tp,800)
end
-- 效果处理：为这张卡赋予‘本回合可以直接攻击对方’的效果，该效果不可被无效，并在回合结束或离场等标准时机重置。
function c30190809.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 本回合这张卡可以对对方进行直接攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
