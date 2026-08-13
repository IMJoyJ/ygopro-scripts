--ガード・ブロック
-- 效果：
-- 对方回合的战斗伤害计算时才能发动。那次战斗发生的对自己的战斗伤害变成0，从自己卡组抽1张卡。
function c24268052.initial_effect(c)
	-- 对方回合的战斗伤害计算时才能发动。那次战斗发生的对自己的战斗伤害变成0，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c24268052.condition)
	e1:SetTarget(c24268052.target)
	e1:SetOperation(c24268052.operation)
	c:RegisterEffect(e1)
end
-- 该效果的发动条件：仅在对方回合的战斗伤害计算时且自己将受到战斗伤害的场合才能发动。
function c24268052.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家不是自己（即对方回合），并且自己本次战斗受到的战斗伤害数值大于0，两者同时满足时条件成立。
	return Duel.GetTurnPlayer()~=tp and Duel.GetBattleDamage(tp)>0
end
-- 发动时的处理函数：进行可发动性检查（自己能否抽1张卡），并登记抽卡的操作信息；本效果不取对象。
function c24268052.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为发动时的检查（chk==0），则返回自己能否抽1张卡，作为能否发动该效果的条件。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置操作信息，将本次连锁的效果分类标记为抽卡（CATEGORY_DRAW），表示处理时自己将抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理函数：先给本方玩家附加一个避免战斗伤害的领域效果（使那次对自己的战斗伤害变为0），然后自己抽1张卡。
function c24268052.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 那次战斗发生的对自己的战斗伤害变成0，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 将避免战斗伤害的效果注册到本方玩家，使该玩家在本次伤害步骤中不受战斗伤害。
	Duel.RegisterEffect(e1,tp)
	-- 以效果原因让本方玩家抽1张卡。
	Duel.Draw(tp,1,REASON_EFFECT)
end
