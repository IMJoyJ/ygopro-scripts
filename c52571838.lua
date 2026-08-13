--忍び寄るデビルマンタ
-- 效果：
-- 这张卡召唤成功时，陷阱卡不能发动。
function c52571838.initial_effect(c)
	-- 对应效果原文：“这张卡召唤成功时，陷阱卡不能发动。” 此处为注册该效果的触发条件与处理函数。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c52571838.sumsuc)
	c:RegisterEffect(e1)
end
-- 召唤成功时的处理函数：在本次连锁结束前加入“陷阱卡不能发动”的限制。
function c52571838.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 设置一个直到连锁结束都有效的连锁限制：后续每次连锁发动时都要经过chlimit函数检查。
	Duel.SetChainLimitTillChainEnd(c52571838.chlimit)
end
-- 连锁限制判定：若发动者发动的效果是陷阱卡且属于卡的发动（EFFECT_TYPE_ACTIVATE），则不允许发动；其他效果不受限制。
function c52571838.chlimit(re,rp,tp)
	return not re:GetHandler():IsType(TYPE_TRAP) or not re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
