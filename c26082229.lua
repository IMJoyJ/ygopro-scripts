--侵略の炎
-- 效果：
-- 这张卡召唤成功时，陷阱卡不能发动。
function c26082229.initial_effect(c)
	-- 这张卡召唤成功时，陷阱卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c26082229.sumsuc)
	c:RegisterEffect(e1)
end
-- 这张卡召唤成功时的处理函数：将本次连锁的连锁限制设置为c26082229.chlimit，直到连锁结束为止。
function c26082229.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 调用Duel.SetChainLimitTillChainEnd，将chlimit函数注册为当前连锁的限制条件，后续所有效果发动都必须通过该条件检查。
	Duel.SetChainLimitTillChainEnd(c26082229.chlimit)
end
-- 连锁限制判定函数：当发动连锁的效果的卡是陷阱卡，且该效果是陷阱卡的发动效果（EFFECT_TYPE_ACTIVATE）时，禁止发动；否则允许发动。即达成“陷阱卡不能发动”的限制。
function c26082229.chlimit(re,rp,tp)
	return not re:GetHandler():IsType(TYPE_TRAP) or not re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
