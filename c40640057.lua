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
-- 发动条件判断：必须为对方回合且自己即将受到战斗伤害，即当前回合玩家不是tp且tp的战斗伤害大于0。
function c40640057.con(e,tp,eg,ep,ev,re,r,rp)
	-- 判断条件：Duel.GetTurnPlayer()~=tp（对方回合）且Duel.GetBattleDamage(tp)>0（自己将受到战斗伤害）。
	return Duel.GetTurnPlayer()~=tp and Duel.GetBattleDamage(tp)>0
end
-- 代价处理：确认代价时检查此卡是否可以从手牌丢弃；执行时将此卡送去墓地作为发动代价。
function c40640057.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡从手牌送去墓地，丢弃原因标记为REASON_COST（代价）和REASON_DISCARD（丢弃）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 效果处理：给自己（tp）设置一个避免战斗伤害的永续效果（影响玩家），持续到伤害步骤结束，使这次战斗对自己的战斗伤害变成0。
function c40640057.op(e,tp,eg,ep,ev,re,r,rp)
	-- 那次战斗发生的对自己的战斗伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 将避免战斗伤害的效果注册给己方玩家tp，使其在本次伤害步骤内生效。
	Duel.RegisterEffect(e1,tp)
end
