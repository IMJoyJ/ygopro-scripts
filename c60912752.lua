--異次元の境界線
-- 效果：
-- 自己墓地里没有魔法卡存在的场合，双方玩家都不能进入战斗阶段。
function c60912752.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己墓地里没有魔法卡存在的场合，双方玩家都不能进入战斗阶段。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BP)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c60912752.bpcon)
	c:RegisterEffect(e2)
end
-- 定义不能进入战斗阶段效果的生效条件函数
function c60912752.bpcon(e)
	-- 检查自己墓地是否存在魔法卡，若不存在则满足条件
	return not Duel.IsExistingMatchingCard(Card.IsType,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,TYPE_SPELL)
end
