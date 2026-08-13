--魔力の棘
-- 效果：
-- 对方的手卡丢弃去墓地时，每丢弃1张卡就给与对方基本分500分的伤害。
function c53119267.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对方的手卡丢弃去墓地时，每丢弃1张卡就给与对方基本分500分的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c53119267.damop)
	c:RegisterEffect(e2)
end
-- 过滤出此前在对方手牌、由对方控制、且因丢弃原因被送去墓地的卡，以判定哪些卡属于“对方的手卡丢弃去墓地”。
function c53119267.filter(c,tp)
	return c:IsPreviousLocation(LOCATION_HAND) and c:IsControler(1-tp) and c:IsPreviousControler(1-tp)
		and c:IsReason(REASON_DISCARD)
end
-- 统计本次送去墓地的卡中满足“对方手卡丢弃”条件的数量，作为后续伤害计算的基础。
function c53119267.damop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(c53119267.filter,nil,tp)
	-- 给与对方玩家（1-tp）500点乘以丢弃张数的效果伤害。
	Duel.Damage(1-tp,ct*500,REASON_EFFECT)
end
