--サモンチェーン
-- 效果：
-- ①：同一连锁上没有复数次同名卡的效果发动的场合，那个连锁3以后才能发动。这个回合自己可以进行通常召唤最多3次。
function c9952083.initial_effect(c)
	-- ①：同一连锁上没有复数次同名卡的效果发动的场合，那个连锁3以后才能发动。这个回合自己可以进行通常召唤最多3次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c9952083.condition)
	e1:SetTarget(c9952083.target)
	e1:SetOperation(c9952083.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定函数：要求当前连锁为连锁3以后（Duel.GetCurrentChain()>1）、当前连锁上没有同名卡效果重复发动（Duel.CheckChainUniqueness()）、且发动者是自己（Duel.GetTurnPlayer()==tp）。
function c9952083.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否满足全部发动条件：当前连锁序号大于1（即连锁3以后）、当前连锁不存在同名卡重复发动、且当前回合玩家是自己。
	return Duel.GetCurrentChain()>1 and Duel.CheckChainUniqueness() and Duel.GetTurnPlayer()==tp
end
-- 发动时点合法性检查（chk==0）：检索当前玩家被适用的通常召唤次数上限，若上限值小于3则允许发动，否则不能发动。
function c9952083.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=0
		-- 获取当前玩家受到的所有EFFECT_SET_SUMMON_COUNT_LIMIT（通常召唤次数限制）效果，并存入表ce供后续遍历取最大值。
		local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_SET_SUMMON_COUNT_LIMIT)}
		for _,te in ipairs(ce) do
			ct=math.max(ct,te:GetValue())
		end
		return ct<3
	end
end
-- 效果处理函数：创建一个永续效果，设置为EFFECT_TYPE_FIELD、EFFECT_SET_SUMMON_COUNT_LIMIT，以玩家为对象，只影响我方，将通常召唤次数上限设为3，并在结束阶段重置。
function c9952083.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合自己可以进行通常召唤最多3次。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(3)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将e1效果注册给tp玩家，使该通常召唤次数上限为3的效果在当前回合生效。
	Duel.RegisterEffect(e1,tp)
end
