--和睦の使者
-- 效果：
-- ①：这个回合，自己怪兽不会被战斗破坏，自己受到的战斗伤害变成0。
function c12607053.initial_effect(c)
	-- ①：这个回合，自己怪兽不会被战斗破坏，自己受到的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	-- 发动条件为战斗阶段开始时
	e1:SetCondition(aux.bpcon)
	e1:SetOperation(c12607053.activate)
	c:RegisterEffect(e1)
end
-- 效果处理函数，用于执行卡片效果的逻辑
function c12607053.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使自己受到的战斗伤害变成0
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1注册给玩家tp
	Duel.RegisterEffect(e1,tp)
	-- 使自己怪兽不会被战斗破坏
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetValue(1)
	-- 将效果e2注册给玩家tp
	Duel.RegisterEffect(e2,tp)
end
