--ガード・ブロック
-- 效果：
-- 对方回合的战斗伤害计算时才能发动。那次战斗发生的对自己的战斗伤害变成0，从自己卡组抽1张卡。
function c24268052.initial_effect(c)
	-- 效果发动条件：对方回合的战斗伤害计算时才能发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c24268052.condition)
	e1:SetTarget(c24268052.target)
	e1:SetOperation(c24268052.operation)
	c:RegisterEffect(e1)
end
-- 判断是否为对方回合且自己受到战斗伤害
function c24268052.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方回合且自己受到战斗伤害
	return Duel.GetTurnPlayer()~=tp and Duel.GetBattleDamage(tp)>0
end
-- 效果处理目标：检查是否可以抽卡
function c24268052.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理流程：使自己不受到战斗伤害并抽1张卡
function c24268052.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使自己在本次战斗中不受到战斗伤害
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 让玩家抽1张卡
	Duel.Draw(tp,1,REASON_EFFECT)
end
