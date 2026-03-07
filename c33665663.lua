--炎舞－「開陽」
-- 效果：
-- 这张卡发动的回合，自己场上的兽战士族怪兽向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。此外，只要这张卡在场上存在，自己场上的兽战士族怪兽的攻击力上升300。
function c33665663.initial_effect(c)
	-- 这张卡发动的回合，自己场上的兽战士族怪兽向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。此外，只要这张卡在场上存在，自己场上的兽战士族怪兽的攻击力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用
	e1:SetCondition(aux.dscon)
	e1:SetOperation(c33665663.activate)
	c:RegisterEffect(e1)
	-- 此外，只要这张卡在场上存在，自己场上的兽战士族怪兽的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	-- 选择场上的兽战士族怪兽作为效果的对象
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_BEASTWARRIOR))
	e2:SetValue(300)
	c:RegisterEffect(e2)
end
-- 效果发动时，使自己场上的兽战士族怪兽获得贯穿伤害效果
function c33665663.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使自己场上的兽战士族怪兽获得贯穿伤害效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 选择场上的兽战士族怪兽作为效果的对象
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_BEASTWARRIOR))
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
