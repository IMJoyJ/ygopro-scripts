--ネクロ・ガードナー
-- 效果：
-- ①：对方回合把墓地的这张卡除外才能发动。这个回合，对方怪兽的攻击只有1次无效。
function c4906301.initial_effect(c)
	-- 效果原文内容：①：对方回合把墓地的这张卡除外才能发动。这个回合，对方怪兽的攻击只有1次无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4906301,0))  --"1次攻击无效"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_ATTACK)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c4906301.condition)
	-- 将此卡从游戏中除外作为费用
	e1:SetCost(aux.bfgcost)
	e1:SetOperation(c4906301.operation)
	c:RegisterEffect(e1)
end
-- 效果原文内容：对方回合把墓地的这张卡除外才能发动。
function c4906301.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家不是发动玩家且满足战斗阶段条件
	return Duel.GetTurnPlayer()~=tp and aux.bpcon(e,tp,eg,ep,ev,re,r,rp)
end
-- 检索满足条件的卡片组、将目标怪兽特殊召唤
function c4906301.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果此时有攻击怪兽则无效其攻击
	if Duel.GetAttacker() then Duel.NegateAttack()
	else
		-- 效果原文内容：这个回合，对方怪兽的攻击只有1次无效。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ATTACK_ANNOUNCE)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetOperation(c4906301.disop)
		-- 将效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 效果作用
function c4906301.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送卡片发动提示
	Duel.Hint(HINT_CARD,0,4906301)
	-- 无效此次攻击
	Duel.NegateAttack()
end
