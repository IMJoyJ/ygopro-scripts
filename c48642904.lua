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
-- 本卡发动时，先创建一个场地持续效果，使对方主要怪兽区的怪兽不能变更表示形式，并持续到下个对方回合结束。
function c48642904.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 对方不能把怪兽的表示形式变更。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将上述限制效果注册到场上，并由发动者tp控制其生效，使该效果实际开始适用。
	Duel.RegisterEffect(e1,tp)
end
