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
-- 判断此卡是否从场上被破坏进入墓地
function c46710683.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_DESTROY)
end
-- 创建一个影响自己的永续效果，使自己在该回合内受到的战斗伤害变为0
function c46710683.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合自己受到的战斗伤害只有1次变成0
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL+PHASE_END)
	-- 将效果e1注册给玩家tp
	Duel.RegisterEffect(e1,tp)
end
