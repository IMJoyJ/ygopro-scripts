--和睦の使者
-- 效果：
-- ①：这个回合，自己怪兽不会被战斗破坏，自己受到的战斗伤害变成0。
function c12607053.initial_effect(c)
	-- ①：这个回合，自己怪兽不会被战斗破坏，自己受到的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	-- 设置效果发动条件为当前处于战斗阶段（或可进入战斗阶段时），即只能在战斗阶段中发动。
	e1:SetCondition(aux.bpcon)
	e1:SetOperation(c12607053.activate)
	c:RegisterEffect(e1)
end
-- 效果处理时：给己方玩家注册本回合内受到的战斗伤害变为0的永续效果，并给自己场上的怪兽注册本回合内不会被战斗破坏的永续效果，两者都在结束阶段重置。
function c12607053.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 自己受到的战斗伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将避免战斗伤害的永续效果注册给己方玩家，使己方本回合受到的所有战斗伤害变为0。
	Duel.RegisterEffect(e1,tp)
	-- 自己怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetValue(1)
	-- 将不会被战斗破坏的永续效果注册给己方场上的怪兽，使己方怪兽本回合不会被战斗破坏。
	Duel.RegisterEffect(e2,tp)
end
