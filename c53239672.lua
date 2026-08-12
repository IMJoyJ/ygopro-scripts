--スピリットバリア
-- 效果：
-- 只要自己场上存在怪兽，对这张卡的控制者的战斗伤害变为0。
function c53239672.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要自己场上存在怪兽，对这张卡的控制者的战斗伤害变为0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetCondition(c53239672.condition)
	c:RegisterEffect(e2)
end
-- 检查自己场上是否存在怪兽
function c53239672.condition(e)
	-- 判断我方主要怪兽区是否有怪兽数量大于0
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)>0
end
