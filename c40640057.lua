--クリボー
-- 效果：
-- ①：对方怪兽的攻击要让自己受到战斗伤害的伤害计算时，把这张卡从手卡丢弃才能发动。那次战斗发生的对自己的战斗伤害变成0。
function c40640057.initial_effect(c)
	-- ①：对方怪兽的攻击要让自己受到战斗伤害的伤害计算时，把这张卡从手卡丢弃才能发动。那次战斗发生的对自己的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40640057,0))  --"战斗伤害变成0"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c40640057.con)
	e1:SetCost(c40640057.cost)
	e1:SetOperation(c40640057.op)
	c:RegisterEffect(e1)
end
-- 伤害计算时的发动条件判断
function c40640057.con(e,tp,eg,ep,ev,re,r,rp)
	-- 对方怪兽攻击且自己受到战斗伤害
	return Duel.GetTurnPlayer()~=tp and Duel.GetBattleDamage(tp)>0
end
-- 丢弃手卡的费用支付
function c40640057.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将效果卡本身送去墓地作为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 效果发动后设置避免战斗伤害的效果
function c40640057.op(e,tp,eg,ep,ev,re,r,rp)
	-- 那次战斗发生的对自己的战斗伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 将避免战斗伤害的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
