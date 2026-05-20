--天変地異
-- 效果：
-- 只要这张卡在场上存在，双方玩家把卡组上下翻转过来进行决斗。
function c62966332.initial_effect(c)
	-- 开启全局卡组翻转检查标记，用于系统处理卡组上下翻转的状态
	Duel.EnableGlobalFlag(GLOBALFLAG_DECK_REVERSE_CHECK)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，双方玩家把卡组上下翻转过来进行决斗。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_REVERSE_DECK)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,1)
	c:RegisterEffect(e2)
end
