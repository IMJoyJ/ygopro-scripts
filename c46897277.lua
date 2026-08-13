--エレキツネ
-- 效果：
-- 这张卡被对方破坏的场合，那个回合对方不能作怪兽的特殊召唤以及把魔法·陷阱·效果怪兽的效果发动。
function c46897277.initial_effect(c)
	-- 这张卡被对方破坏的场合，那个回合对方不能作怪兽的特殊召唤以及把魔法·陷阱·效果怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46897277,0))  --"对方发动限制"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c46897277.condition)
	e1:SetOperation(c46897277.operation)
	c:RegisterEffect(e1)
end
-- 判断是否满足触发条件：破坏者是对方（rp==1-tp），且这张卡在被破坏前由我方控制（IsPreviousControler(tp)），即被对方破坏。
function c46897277.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 效果处理：向对方玩家附加两项限制——不能发动魔法·陷阱·效果怪兽的效果，也不能特殊召唤怪兽，这些限制持续到这个回合结束。
function c46897277.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 不能把魔法·陷阱·效果怪兽的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“对方不能发动效果”的限制效果注册到对方玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
	-- 不能作怪兽的特殊召唤。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(0,1)
	-- 将“对方不能特殊召唤怪兽”的限制效果注册到对方玩家，持续到回合结束。
	Duel.RegisterEffect(e2,tp)
end
