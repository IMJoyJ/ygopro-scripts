--エレキリン
-- 效果：
-- ①：这张卡可以直接攻击。
-- ②：这张卡直接攻击给与对方战斗伤害的场合发动。这个回合，对方不能把魔法·陷阱·怪兽的效果发动。
function c402568.initial_effect(c)
	-- ①：这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- ②：这张卡直接攻击给与对方战斗伤害的场合发动。这个回合，对方不能把魔法·陷阱·怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(402568,0))  --"对方发动限制"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c402568.condition)
	e2:SetOperation(c402568.operation)
	c:RegisterEffect(e2)
end
-- 判断是否为直接攻击造成的战斗伤害且攻击对象为空
function c402568.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方受到战斗伤害且没有攻击对象
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 设置对方在本回合不能发动魔法·陷阱·怪兽效果
function c402568.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 对方发动限制
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给对方玩家
	Duel.RegisterEffect(e1,tp)
end
