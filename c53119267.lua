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
-- 过滤满足条件的卡片组，即丢弃到墓地且来自对方手牌的怪兽
function c53119267.filter(c,tp)
	return c:IsPreviousLocation(LOCATION_HAND) and c:IsControler(1-tp) and c:IsPreviousControler(1-tp)
		and c:IsReason(REASON_DISCARD)
end
-- 计算符合条件的卡片数量并给予对方基本分伤害
function c53119267.damop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(c53119267.filter,nil,tp)
	-- 以效果原因对对方造成相当于丢弃卡数乘以500的基本分伤害
	Duel.Damage(1-tp,ct*500,REASON_EFFECT)
end
