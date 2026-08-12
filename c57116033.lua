--ハネクリボー
-- 效果：
-- ①：场上的这张卡被破坏送去墓地的场合发动。这个回合，自己受到的战斗伤害变成0。
function c57116033.initial_effect(c)
	-- ①：场上的这张卡被破坏送去墓地的场合发动。这个回合，自己受到的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57116033,0))  --"战斗伤害变成0"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c57116033.con)
	e1:SetOperation(c57116033.op)
	c:RegisterEffect(e1)
end
-- 检查发动条件：这张卡是否原本在场上，并且是因为被破坏而送去墓地
function c57116033.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY)
end
-- 执行效果：创建一个在回合结束前使自己受到的战斗伤害变成0的全局效果
function c57116033.op(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己受到的战斗伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该战斗伤害免疫效果注册给发动效果的玩家
	Duel.RegisterEffect(e1,tp)
end
