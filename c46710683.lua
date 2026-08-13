--BF－銀盾のミストラル
-- 效果：
-- 场上存在的这张卡被破坏送去墓地的场合，这个回合自己受到的战斗伤害只有1次变成0。
function c46710683.initial_effect(c)
	-- 场上存在的这张卡被破坏送去墓地的场合，这个回合自己受到的战斗伤害只有1次变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46710683,0))  --"这个回合自己受到的战斗伤害只有1次变成0"
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c46710683.condition)
	e1:SetOperation(c46710683.operation)
	c:RegisterEffect(e1)
end
-- 发动条件：这张卡被破坏送去墓地前存在于场上，且是被破坏（REASON_DESTROY）而送去墓地的。
function c46710683.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_DESTROY)
end
-- 效果处理：创建一个影响己方玩家的领域效果，使这个回合自己受到的战斗伤害仅1次变成0，并在伤害计算阶段结束时或结束阶段时重置。
function c46710683.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合自己受到的战斗伤害只有1次变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL+PHASE_END)
	-- 将上述避免战斗伤害的效果注册给当前玩家tp，使该效果在tp方生效。
	Duel.RegisterEffect(e1,tp)
end
