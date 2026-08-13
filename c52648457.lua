--ゴーゴンの眼
-- 效果：
-- 结束阶段结束前，场上存在的守备表示的怪兽的效果无效化。
function c52648457.initial_effect(c)
	-- 结束阶段结束前，场上存在的守备表示的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c52648457.activate)
	c:RegisterEffect(e1)
end
-- 发动后，在场上设置一个持续到结束阶段的领域效果，使场上所有守备表示的怪兽的效果无效化。
function c52648457.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 场上存在的守备表示的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c52648457.distg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述无效化效果注册到当前玩家场上，使其开始适用。
	Duel.RegisterEffect(e1,tp)
end
-- 判断怪兽是否为守备表示的筛选条件，作为该无效化效果的目标对象条件。
function c52648457.distg(e,c)
	return c:IsDefensePos()
end
