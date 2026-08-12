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
-- 在发动时，创建一个影响全场的永续效果，用于使怪兽效果无效。
function c52648457.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 结束阶段结束前，场上存在的守备表示的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c52648457.distg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该效果注册给全局环境，使其在指定玩家的回合中生效。
	Duel.RegisterEffect(e1,tp)
end
-- 判断目标怪兽是否为守备表示，用于筛选被无效化的对象。
function c52648457.distg(e,c)
	return c:IsDefensePos()
end
