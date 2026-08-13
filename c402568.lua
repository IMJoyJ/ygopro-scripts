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
-- 定义效果的发动条件函数：仅当本卡直接攻击给对方造成战斗伤害时，该诱发效果才满足发动条件。
function c402568.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定本次战斗伤害是否为直接攻击：ep≠tp 表示受到伤害的是对方玩家，Duel.GetAttackTarget()==nil 表示攻击时没有攻击对象（即直接攻击）。
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 效果处理：创建一个影响对方玩家的永续效果，使其不能发动魔法·陷阱·怪兽的任何效果；该效果在结束阶段重置。
function c402568.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，对方不能把魔法·陷阱·怪兽的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将新建的限制效果注册给本卡控制者 tp，使该效果立即适用，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
