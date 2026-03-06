--断層地帯
-- 效果：
-- 守备表示的岩石族怪兽被攻击，攻击怪兽的控制者受到战斗伤害的场合，那个战斗伤害变成2倍。
function c28120197.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 守备表示的岩石族怪兽被攻击，攻击怪兽的控制者受到战斗伤害的场合，那个战斗伤害变成2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetCondition(c28120197.dcon1)
	e2:SetValue(DOUBLE_DAMAGE)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetTargetRange(0,1)
	e3:SetCondition(c28120197.dcon2)
	c:RegisterEffect(e3)
end
-- 当攻击怪兽的控制者与场地卡控制者相同时，且攻击目标为守备表示的岩石族怪兽时，触发效果
function c28120197.dcon1(e)
	-- 获取此次战斗中攻击的怪兽
	local a=Duel.GetAttacker()
	-- 获取此次战斗中被攻击的怪兽
	local d=Duel.GetAttackTarget()
	return a:GetControler()==e:GetHandlerPlayer()
		and d and d:IsDefensePos() and d:IsRace(RACE_ROCK)
end
-- 当攻击怪兽的控制者与场地卡控制者不同时，且攻击目标为守备表示的岩石族怪兽时，触发效果
function c28120197.dcon2(e)
	-- 获取此次战斗中攻击的怪兽
	local a=Duel.GetAttacker()
	-- 获取此次战斗中被攻击的怪兽
	local d=Duel.GetAttackTarget()
	return a:GetControler()==1-e:GetHandlerPlayer()
		and d and d:IsDefensePos() and d:IsRace(RACE_ROCK)
end
