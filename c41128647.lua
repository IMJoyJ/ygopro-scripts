--ダイナミックP
-- 效果：
-- ①：场上的「雾动机龙」怪兽的攻击力·守备力上升300。
-- ②：自己的「雾动机龙」怪兽进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
function c41128647.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①中“场上的「雾动机龙」怪兽的攻击力·守备力上升300”的前半部分：使场上的「雾动机龙」怪兽攻击力上升300（守备力上升由后续克隆的e3效果处理）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置攻击力上升效果的作用对象筛选条件：只对持有「雾动机龙」字段（0xd8）的怪兽生效。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xd8))
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：“自己的「雾动机龙」怪兽进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。”
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(0,1)
	e4:SetValue(1)
	e4:SetCondition(c41128647.actcon)
	c:RegisterEffect(e4)
end
-- 过滤函数：判断一张卡是否为表侧表示、属于「雾动机龙」字段（0xd8）且控制者为tp，用于后续确认参与战斗的怪兽是否满足条件。
function c41128647.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xd8) and c:IsControler(tp)
end
-- 效果②的适用条件：当前战斗阶段中，攻击怪兽或被攻击怪兽存在己方控制的表侧表示「雾动机龙」怪兽时，该限制效果生效。
function c41128647.actcon(e)
	local tp=e:GetHandlerPlayer()
	-- 获取当前正在战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取当前被攻击的怪兽（直接攻击时可能为nil）。
	local d=Duel.GetAttackTarget()
	return (a and c41128647.cfilter(a,tp)) or (d and c41128647.cfilter(d,tp))
end
