--正々堂々
-- 效果：
-- 双方玩家必须在各自的回合把手卡全部持续公开。
function c8951260.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 双方玩家必须在各自的回合把手卡全部持续公开。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PUBLIC)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetCondition(c8951260.con1)
	c:RegisterEffect(e2)
	-- 双方玩家必须在各自的回合把手卡全部持续公开。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_PUBLIC)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_HAND)
	e3:SetCondition(c8951260.con2)
	c:RegisterEffect(e3)
end
-- 定义自身手牌公开效果的生效条件（仅在自身回合生效）
function c8951260.con1(e)
	-- 判断当前回合玩家是否为该卡控制者
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
-- 定义对方手牌公开效果的生效条件（仅在对方回合生效）
function c8951260.con2(e)
	-- 判断当前回合玩家是否为该卡控制者的对手
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
