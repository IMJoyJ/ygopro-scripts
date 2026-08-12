--ネクロ・ガードナー
-- 效果：
-- ①：对方回合把墓地的这张卡除外才能发动。这个回合，对方怪兽的攻击只有1次无效。
function c4906301.initial_effect(c)
	-- ①：对方回合把墓地的这张卡除外才能发动。这个回合，对方怪兽的攻击只有1次无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4906301,0))  --"1次攻击无效"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_ATTACK)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c4906301.condition)
	-- 设置发动Cost为将墓地的这张卡除外
	e1:SetCost(aux.bfgcost)
	e1:SetOperation(c4906301.operation)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件
function c4906301.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为对方回合，且处于可以进行战斗相关操作的时点或阶段
	return Duel.GetTurnPlayer()~=tp and aux.bpcon(e,tp,eg,ep,ev,re,r,rp)
end
-- 定义效果的发动处理
function c4906301.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果是在攻击宣言时发动，则直接无效当前的攻击
	if Duel.GetAttacker() then Duel.NegateAttack()
	else
		-- 这个回合，对方怪兽的攻击只有1次无效。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ATTACK_ANNOUNCE)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetOperation(c4906301.disop)
		-- 将无效攻击的全局效果注册给发动玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 定义无效攻击的事件触发处理
function c4906301.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 在决斗界面展示“死灵守卫者”的卡片发动提示
	Duel.Hint(HINT_CARD,0,4906301)
	-- 无效当前的攻击
	Duel.NegateAttack()
end
