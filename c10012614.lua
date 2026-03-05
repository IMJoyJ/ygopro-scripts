--勇気の旗印
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的怪兽的攻击力在自己战斗阶段内上升200。
function c10012614.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上的怪兽的攻击力在自己战斗阶段内上升200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c10012614.con)
	e2:SetValue(200)
	c:RegisterEffect(e2)
end
-- 判断是否处于自己战斗阶段内
function c10012614.con(e)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	-- 获取当前回合玩家
	local tp=Duel.GetTurnPlayer()
	return tp==e:GetHandlerPlayer() and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
