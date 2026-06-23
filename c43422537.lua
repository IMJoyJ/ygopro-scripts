--二重召喚
-- 效果：
-- ①：这个回合自己可以进行通常召唤最多2次。
function c43422537.initial_effect(c)
	-- ①：这个回合自己可以进行通常召唤最多2次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c43422537.target)
	e1:SetOperation(c43422537.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组
function c43422537.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=0
		-- 获取玩家受 EFFECT_SET_SUMMON_COUNT_LIMIT 效果影响的情况
		local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_SET_SUMMON_COUNT_LIMIT)}
		for _,te in ipairs(ce) do
			ct=math.max(ct,te:GetValue())
		end
		return ct<2
	end
end
-- 将目标怪兽特殊召唤
function c43422537.activate(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这个回合自己可以进行通常召唤最多2次。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(2)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把效果作为玩家的效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
end
