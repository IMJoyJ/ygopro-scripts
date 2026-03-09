--催眠術
-- 效果：
-- ①：下次的对方回合，对方不能把怪兽的表示形式变更。
function c48642904.initial_effect(c)
	-- ①：下次的对方回合，对方不能把怪兽的表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c48642904.regop)
	c:RegisterEffect(e1)
end
-- 注册触发效果，使催眠术在发动时执行后续处理
function c48642904.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 下次的对方回合，对方不能把怪兽的表示形式变更。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将表示形式变更禁止效果注册给对方玩家
	Duel.RegisterEffect(e1,tp)
end
