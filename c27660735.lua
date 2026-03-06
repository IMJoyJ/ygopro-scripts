--SR三つ目のダイス
-- 效果：
-- ①：对方回合把墓地的这张卡除外才能发动。这个回合，对方怪兽的攻击只有1次无效。
function c27660735.initial_effect(c)
	-- 创建一个诱发即时效果，用于处理卡片效果的发动条件与执行操作
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27660735,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_ATTACK)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c27660735.condition)
	-- 设置效果的发动费用为将此卡从墓地除外
	e1:SetCost(aux.bfgcost)
	e1:SetOperation(c27660735.operation)
	c:RegisterEffect(e1)
end
-- 判断是否处于对方回合且可以进行战斗相关操作的时点
function c27660735.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家不是发动玩家，并且满足战斗阶段的条件
	return Duel.GetTurnPlayer()~=tp and aux.bpcon(e,tp,eg,ep,ev,re,r,rp)
end
-- 效果发动时的处理函数，根据是否有攻击怪兽决定是否立即无效攻击或注册后续效果
function c27660735.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果当前有攻击怪兽，则立即无效该次攻击
	if Duel.GetAttacker() then Duel.NegateAttack()
	else
		-- 创建一个持续效果，用于在对方怪兽攻击宣言时无效其攻击
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ATTACK_ANNOUNCE)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetOperation(c27660735.disop)
		-- 将该效果注册给发动玩家，使其在指定时点生效
		Duel.RegisterEffect(e1,tp)
	end
end
-- 无效攻击时的处理函数，用于提示卡片发动并执行无效攻击操作
function c27660735.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，显示该卡被发动
	Duel.Hint(HINT_CARD,0,27660735)
	-- 无效当前的攻击行为
	Duel.NegateAttack()
end
