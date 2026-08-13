--SR三つ目のダイス
-- 效果：
-- ①：对方回合把墓地的这张卡除外才能发动。这个回合，对方怪兽的攻击只有1次无效。
function c27660735.initial_effect(c)
	-- ①：对方回合把墓地的这张卡除外才能发动。这个回合，对方怪兽的攻击只有1次无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27660735,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_ATTACK)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c27660735.condition)
	-- 设置发动代价：将墓地的这张卡除外。
	e1:SetCost(aux.bfgcost)
	e1:SetOperation(c27660735.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件：仅在对方回合且当前处于战斗阶段（或可以进入战斗阶段）时才能发动。
function c27660735.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是对方回合，且处于战斗阶段。
	return Duel.GetTurnPlayer()~=tp and aux.bpcon(e,tp,eg,ep,ev,re,r,rp)
end
-- 效果处理：若已有攻击宣言，则直接无效那次攻击；否则在本回合内设置持续效果，在攻击宣言时无效该攻击。
function c27660735.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前已有攻击怪兽，则直接无效那次攻击。
	if Duel.GetAttacker() then Duel.NegateAttack()
	else
		-- 这个回合，对方怪兽的攻击只有1次无效。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ATTACK_ANNOUNCE)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetOperation(c27660735.disop)
		-- 将该持续效果注册到当前回合玩家侧，使其在本次战斗中生效。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 持续效果的发动处理：在对方怪兽攻击宣言时，无效该次攻击。
function c27660735.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 向全场玩家展示该卡的效果发动动画（卡片编号27660735）。
	Duel.Hint(HINT_CARD,0,27660735)
	-- 无效此次攻击。
	Duel.NegateAttack()
end
