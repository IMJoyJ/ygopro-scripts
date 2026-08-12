--ニュート
-- 效果：
-- ①：这张卡反转的场合发动。这张卡的攻击力·守备力上升500。
-- ②：这张卡被战斗破坏的场合发动。让把这张卡破坏的怪兽的攻击力·守备力下降500。
function c78636495.initial_effect(c)
	-- ①：这张卡反转的场合发动。这张卡的攻击力·守备力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78636495,0))  --"攻守上升500"
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(c78636495.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗破坏的场合发动。让把这张卡破坏的怪兽的攻击力·守备力下降500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78636495,1))  --"攻守下降500"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetOperation(c78636495.desop)
	c:RegisterEffect(e2)
end
-- 反转效果的实际处理：使自身攻击力和守备力上升500
function c78636495.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡的攻击力·守备力上升500
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
end
-- 被战斗破坏时效果的实际处理：使把这张卡破坏的怪兽的攻击力和守备力下降500
function c78636495.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次战斗的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 如果自身是攻击怪兽，则将把自身破坏的怪兽（防守怪兽）设为效果目标
	if c==tc then tc=Duel.GetAttackTarget() end
	if not tc:IsRelateToBattle() then return end
	-- 让把这张卡破坏的怪兽的攻击力·守备力下降500
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(-500)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	tc:RegisterEffect(e2)
end
