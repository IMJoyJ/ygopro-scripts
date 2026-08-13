--二重召喚
-- 效果：
-- ①：这个回合自己可以进行通常召唤最多2次。
function c43422537.initial_effect(c)
	-- ①：这个回合，自己可以进行通常召唤最多2次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c43422537.target)
	e1:SetOperation(c43422537.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：检测当前玩家本回合的通常召唤次数上限是否小于2，只有小于2时才能发动此卡。
function c43422537.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=0
		-- 获取当前玩家tp受到的所有'每回合召唤次数限制'效果，返回table存入ce。
		local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_SET_SUMMON_COUNT_LIMIT)}
		for _,te in ipairs(ce) do
			ct=math.max(ct,te:GetValue())
		end
		return ct<2
	end
end
-- 效果处理时，给当前玩家tp施加一个持续到回合结束的『每回合通常召唤次数上限=2』的永续效果（影响玩家），从而让该玩家本回合可以进行最多2次通常召唤。
function c43422537.activate(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这个回合，自己可以进行通常召唤最多2次。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(2)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将新生成的召唤次数限制效果e1注册到当前玩家tp，使其实际生效。
	Duel.RegisterEffect(e1,tp)
end
