--ライライダー
-- 效果：
-- 这张卡和对方怪兽进行过战斗的场合，那只怪兽只要在场上表侧表示存在不能攻击。
function c31173519.initial_effect(c)
	-- 这张卡和对方怪兽进行过战斗的场合，那只怪兽只要在场上表侧表示存在不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31173519,0))  --"攻击限制"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(c31173519.condition)
	e1:SetOperation(c31173519.operation)
	c:RegisterEffect(e1)
end
-- 判断触发条件：获取此卡战斗的对方怪兽，若战斗对象存在且未被战斗破坏确定，则条件成立。
function c31173519.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	return tc and not tc:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 处理效果：获取战斗对象怪兽，为其注册“不能攻击”的永续效果，并设置效果在该怪兽离场/回手牌/回卡组/送入墓地/除外等标准重置时失效，即该怪兽只要在场上表侧表示存在就不能攻击。
function c31173519.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	-- 那只怪兽只要在场上表侧表示存在不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
end
